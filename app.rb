# app.rb
require 'rubygems'
require 'bundler'
Bundler.require
require './config/environments'
require './models/user'
require './models/facebook'
require './models/spot'
require './models/answer'
require './models/relationship'

Rabl.register!

use Rack::PostBodyContentTypeParser
use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'veoveo' and password == 'lolumad'
end

before do
  content_type 'application/json'
  api_token = request.env['HTTP_X_VEOVEO_API_TOKEN']
  @current_user = User.find_by_api_token(api_token) if api_token
end

get '/' do
  "Hello, world!"
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

get '/answers' do
  halt 401 unless @current_user
  followed_users_ids = @current_user.followed_users.map(&:id)
  @answers = Answer.includes(:spot, :user).where(:user_id => followed_users_ids)
  rabl :get_answers, :format => "json"
end

get '/spots' do
  halt 401 unless @current_user
  status 200
  @spots = Spot.in_region(params['region'])
  rabl :get_spots, :format => "json"
end

get '/spots/:id' do
  halt 401 unless @current_user
  @spot = Spot.includes(:answers => :user).find(params[:id])
  if @spot
    status 200
    rabl :get_spots_id, :format => "json"
  else
    status 400
    body("spot with #{params[:id]} does not exist".to_json)
  end
end

post '/users/avatar' do
  halt 401 unless @current_user
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
  halt 401 unless @current_user
  @user = User.includes(:answers => :spot).find(params[:id])
  if @user
    status 200
    rabl :get_users_id, :format => "json"
  else
    status 400
    body("User not found".to_json)
  end
end

post '/answers' do
  halt 401 unless @current_user

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

post '/spots' do
  halt 401 unless @current_user
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
