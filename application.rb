require 'sinatra'
require './avatar_generator'

configure do
  set :app_file, __FILE__
  set :bind, '0.0.0.0'
  set :port, ENV['PORT']
end

before do
  content_type "image/png"
end

get '/avatar' do
  name = params[:name] || '?'
  options = {
    name: name,
    format: 'png'
  }
  AvatarGenerator.avatar_for(options)
end

