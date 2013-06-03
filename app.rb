# app.rb
require 'rubygems'
require 'bundler'
require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/user'
require './models/facebook'

get '/' do
  'Hello world!'
end
