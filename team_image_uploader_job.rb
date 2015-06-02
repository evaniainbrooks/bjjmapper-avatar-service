require 'mongo'
require 'uri'
require './database_config'
require './team_image_uploader'

module TeamImageUploaderJob
  include Mongo

  @queue = "images"
  @connection = MongoClient.new(DATABASE_HOST, DATABASE_PORT).db(DATABASE_DB)

  def self.perform(model, path)
    begin
      uploader = TeamImageUploader.new(model)
      file = File.open(path, "rb")

      uploader.store!(file)

      self.update_model(model['_id'], uploader)

    ensure
      File.delete(path)
    end
  end

  def self.update_model(id, uploader)
    update_params = {
      :image_tiny => cachebust_url( uploader.url(:tiny) ),
      :image => cachebust_url( uploader.url(:small) ),
      :image_large => cachebust_url( uploader.url )
    }
    @connection['teams'].update({ :_id => id }, { "$set" => update_params })
  end

  def self.cachebust_url(url)
    uri = URI.parse(url)
    query_args = URI.decode_www_form(uri.query || '') << ["ts", Time.now.to_i]
    uri.query = URI.encode_www_form(query_args)
    uri.to_s
  end
end
