# dev hint: shotgun login.rb

require 'rubygems'
require 'sinatra'
#require 'kaminari/sinatra'
require 'mongoid'
Dir[File.dirname(__FILE__) + '/../model/*.rb'].each {|file| puts "Requiring #{file}"; require file }
require_relative '../conf/conf.rb'
require_relative '../lib/aux.rb'
require_relative '../conf/db.rb'


configure do
  set :public_folder, Proc.new { File.join(root, "static") }
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  if !session[:identity] then
    session[:previous_url] = request['REQUEST_PATH']
    @error = 'Sorry guacamole, you need to be logged in to do that'
    halt erb(:login_form)
  end
end

get '/' do
  erb "visite youtube"
end

get '/login/form' do 
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from 
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end


get '/secure/place' do
  erb "This is a secret place that only <%=session[:identity]%> has access to!"
end

get '/youtube' do
  erb :youtube
end

get '/ajax/:request/:value' do
  y=Youtube.where(:yid => params[:request].strip).update(if_download: params[:value] == "true")
  params[:request].to_s + " set to #{params[:value]} is done." 
end
