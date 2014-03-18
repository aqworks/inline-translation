require 'rubygems'
require 'sinatra'
require 'coffee_script'



get "/" do
  erb :index
end

get '/js/translation_ui.js' do
  coffee :translation_ui
end
