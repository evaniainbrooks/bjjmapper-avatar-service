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

get '/:width_height/:name/image.png' do
  name = (params[:name] || '?')
  width, height = (params[:width_height] || '100x100').split('x')
  options = {
    name: name,
    width: width.to_i,
    height: height.to_i,
    format: 'png'
  }

  AvatarGenerator.avatar_for(options)
end

