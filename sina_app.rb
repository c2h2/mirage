require 'sinatra'
require_relative 'conf/db.rb'


get '/' do
  
  erb :index
end
