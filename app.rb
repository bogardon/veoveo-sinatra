# app.rb
require 'rubygems'
require 'bundler'
Bundler.require
require './config/environments'
require './models/user'
require './models/facebook'

before do
  content_type 'application/json'
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
