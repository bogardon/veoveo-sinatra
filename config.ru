require 'rubygems'
require 'bundler'
Bundler.require
require './config/environments'
require './models/user'
require './models/facebook'
require './app'
run Sinatra::Application
