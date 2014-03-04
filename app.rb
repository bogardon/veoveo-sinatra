# app.rb
require 'stringio'
require 'rubygems'
require 'bundler'
Bundler.require
require './config/environments'
require './models/user'
require './models/spot'
require './models/answer'
require './models/relationship'
require './models/notification'
require './lib/string'
require './lib/answer_push'
require './lib/follow_push'
require './lib/facebook_push'
require 'pry'

Rabl.register!

use Rack::PostBodyContentTypeParser
use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'veoveo' and password == 'lolumad'
end

before do
  content_type 'application/json'
  unless ["signup", "signin", nil].include?(request.path_info.split('/').last)
    api_token = request.env['HTTP_X_VEOVEO_API_TOKEN']
    @current_user = User.find_by_api_token(api_token) if api_token
    halt 401, "requires api token" unless @current_user
  end
end

get '/' do
  "Hello, world!"
end

get '/spots/nearby' do
  region = params['region']
  @user_ids = @current_user.relationships.map(&:followed_id)
  @spots = Spot.in_region(region).select do |s|
    case @current_user.spots_nearby_push
    when "anyone"
      true
    when "followed"
      @user_ids.include?(s.user_id)
    when "noone"
      false
    end
  end.reject do |s|
    s.answers.any? do |answer|
      answer.user_id == @current_user.id
    end
  end
  rabl :get_spots_nearby, :format => :json
end

get '/users/:id/following' do
  @users = Relationship.includes(:followed => :reverse_relationships).where(:follower_id => params[:id]).map(&:followed)
  if @users
    status 200
    rabl :get_users_id_following, :format => :json
  else
    status 400
  end
end

patch '/users' do
  if @current_user.update_attributes(params['user'])
    status 204
  else
    status 400
  end
end

post '/users/:id/follow' do
  @user_to_follow = User.find(params[:id])
  @relationship = Relationship.new
  @relationship.follower = @current_user
  @relationship.followed = @user_to_follow
  if @relationship && @relationship.save
    status 204
  else
    status 400
  end
end

get '/facebook/find_friends' do
  facebook_ids = @current_user.facebook_friend_ids
  @users = User.includes(:reverse_relationships).where(:facebook_id => facebook_ids)
  if @users
    status 200
    rabl :get_facebook_find_friends, :format => :json
  else
    status 400
  end
end

post '/users/facebook' do
  facebook_access_token = params['facebook_access_token']
  facebook_expires_at = DateTime.parse(params['facebook_expires_at'])
  halt 400 unless facebook_access_token && facebook_expires_at

  graph = Koala::Facebook::API.new(facebook_access_token)

  unless @current_user.facebook_id
    me = graph.get_object("me")
    facebook_id = me['id']
    @current_user.facebook_id = facebook_id
  else
  end

  @current_user.facebook_access_token = facebook_access_token
  @current_user.facebook_expires_at = facebook_expires_at

  if @current_user.save
    status 201
  else
    status 400
  end
end

delete '/users/facebook' do
  @current_user.facebook_id = nil
  @current_user.facebook_access_token = nil
  @current_user.facebook_expires_at = nil
  if @current_user.save
    status 204
  else
    status 400
  end
end

delete '/users/:id/follow' do
  @user_to_unfollow = User.find(params[:id])
  @relationship_to_delete = Relationship.where(:follower_id => @current_user.id, :followed_id => @user_to_unfollow.id).first
  if @relationship_to_delete && @relationship_to_delete.destroy
    status 204
  else
    status 400
  end
end

post '/users/signup' do
  @user = User.sign_up params
  if @user.errors.messages.any?
    status 400
    body(@user.errors.messages.to_json)
  else
    status 201
    rabl :post_users_signup, :format => "json"
  end
end

post '/users/signin' do
  @user = User.sign_in params
  if @user.nil? || @user.errors.messages.any?
    status 400
    body({errors: "incorrect username or password"}.to_json)
  else
    status 201
    rabl :post_users_signin, :format => "json"
  end
end

patch '/notifications' do
  @notifications = Notification.where(:dst_user_id => @current_user.id, :unread => true)
  @notifications.update_all :unread => false
  status 204
end

get '/notifications' do
  @notifications = Notification.includes(:src_user, :notifiable).where(:dst_user_id => @current_user.id).limit(params['limit'].to_i || 10).offset(params['offset'].to_i || 0)

  spot_ids = @notifications.select do |n|
    n.notifiable_type == "Answer"
  end.map do |n|
    n.notifiable.spot_id
  end
  spots_by_id = Spot.find(spot_ids).group_by(&:id)
  @notifications.each do |n|
    next unless n.notifiable_type == "Answer"
    n.notifiable.spot = spots_by_id[n.notifiable.spot_id].first
  end

  rabl :get_notifications, :format => :json
end

get '/answers' do
  followed_users_ids = @current_user.followed_users.map(&:id)
  @answers = Answer.includes(:spot, :user).where(:user_id => followed_users_ids).limit(params['limit'].to_i || 10).offset(params['offset'].to_i || 0)
  rabl :get_answers, :format => "json"
end

get '/spots' do
  status 200
  @spots = Spot.in_region(params['region'])
  @user_ids = @current_user.relationships.map(&:followed_id)
  if params[:following].to_bool
    @spots = @spots.where(:user_id => @user_ids + [@current_user.id])
  end
  rabl :get_spots, :format => "json"
end

get '/spots/:id' do
  @spot = Spot.includes(:answers => :user).includes(:user).find_by_id(params[:id])
  if @spot
    status 200
    rabl :get_spots_id, :format => "json"
  else
    status 400
    body("spot with #{params[:id]} does not exist".to_json)
  end
end

patch '/users/device_token' do
  @current_user.device_token = params[:device_token]
  if @current_user.save
    status 204
  else
    status 400
  end
end

post '/users/avatar' do
  image_data = params['avatar'][:tempfile]
  @current_user.avatar = image_data if image_data
  if @current_user.save
    status 201
    rabl :post_users_avatar, :format => :json
  else
    status 400
    body("fix your request".to_json)
  end
end

get '/users/:id' do
  @user = User.includes(:reverse_relationships).find(params[:id])
  if @user
    status 200
    rabl :get_users_id, :format => "json"
  else
    status 400
    body("User not found".to_json)
  end
end

get '/users/:id/answers' do
  @answers = Answer.includes(:spot).where(:user_id => params[:id]).limit(params['limit'].to_i || 10).offset(params['offset'].to_i || 10)
  rabl :get_users_id_answers, :format => :json
end

post '/answers' do
  @spot = Spot.find(params["spot_id"])

  @answer = Answer.new
  @answer.image = params['image'][:tempfile]
  @answer.user = @current_user
  @answer.spot = @spot

  if @answer.save
    status 201
    rabl :post_answers, :format => "json"
  else
    status 400
    body("i don't know why this failed".to_json)
  end
end

delete '/spots/:id' do
  @spot = Spot.find(params[:id])
  halt 400 unless @spot.user_id == @current_user.id
  if @spot.destroy
    status 204
  else
    status 400
    body("could not delete".to_json)
  end
end

post '/spots' do
  @spot = Spot.new params.slice('latitude', 'longitude', 'hint')
  @spot.user = @current_user

  @answer = Answer.new
  @answer.image = params['image'][:tempfile]
  @answer.user = @current_user

  @spot.answers << @answer

  if @spot.save
    status 201
    rabl :post_spots, :format => "json"
  else
    status 400
    body("something went wrong duh".to_json)
  end
end
