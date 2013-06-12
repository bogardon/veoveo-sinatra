# app.rb
require 'rubygems'
require 'bundler'
Bundler.require
require './config/environments'
require './models/user'
require './models/facebook'

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

post '/users/sign_up' do
  body = request.body.read
  json = JSON.parse(body)
  @user = User.sign_up json
  if @user.errors.messages.any?
    status 400
    body(@user.errors.messages.to_json)
  else
    status 201
    body(@user.to_json)
  end
end

post '/users/sign_in' do
  @user = User.sign_in params
  if @user.nil? || @user.errors.messages.any?
    status 400
    body({errors: "incorrect username or password"}.to_json)
  else
    status 201
    body(@user.to_json)
  end
end
post '/users/avatar' do
  halt 401 unless @current_user
  image_data = params['avatar'][:tempfile]
  @current_user.avatar = image_data if image_data
  if @current_user.save
    status 201
    body(@current_user.to_json)
  else
    status 400
    body("fix your request".to_json)
  end
end

