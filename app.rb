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
  "Hello, world!!"
end
