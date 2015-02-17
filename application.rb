require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json/ext'

require 'resque'

require './database_config'
require './avatar_generator'
require './team_image_uploader'

include Mongo

configure do
  set :app_file, __FILE__
  set :bind, '0.0.0.0'
  set :port, ENV['PORT']

  set :resque_database_name, DATABASE_QUEUE_DB 
  set :database_name, DATABASE_DB

  connection = MongoClient.new(DATABASE_HOST, DATABASE_PORT)
  set :mongo_connection, connection
  set :mongo_db, connection.db(settings.database_name)
  set :queue_db, connection.db(settings.resque_database_name)

  Resque.mongo = settings.queue_db
end

helpers do
  # a helper method to turn a string ID
  # representation into a BSON::ObjectId
  def object_id val
    BSON::ObjectId.from_string(val)
  end

  def document_by_id id, collection
    id = object_id(id) if String === id
    settings.mongo_db[collection].find_one(:_id => id)
  end
end

post '/upload/teams/:team_id/async' do
  content_type :json

  unless params[:file] && params[:file][:tempfile]
    STDERR.puts "Missing file argument, returning 400"
    halt 400
  end

  model = document_by_id(params[:team_id], 'teams')
  halt 404 if model.nil?

  TeamImageUploader.store_async(model, params[:file])

  status 202
end

get '/:width_height/:name/image.png' do
  content_type 'image/png'

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

