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
  body = request.body.read
  json = JSON.parse(body)
  @user = User.sign_in json
  if @user.errors.messages.any?
    status 400
    body(@user.errors.messages.to_json)
  else
    status 201
    body(@user.to_json)
  end
end
