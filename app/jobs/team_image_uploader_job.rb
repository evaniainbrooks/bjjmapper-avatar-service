require 'mongo'
require 'uri'
require_relative '../../database_config'
require_relative '../team_image_uploader'

module TeamImageUploaderJob
  include Mongo

  @queue = "images"
  @connection = Mongo::Client.new(AvatarService::DATABASE_URI)

  def self.perform(id, path)
    begin
      uploader = TeamImageUploader.new(id)
      file = File.open(path, "rb")

      uploader.store!(file)

      self.update_model(id, uploader)

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
    @connection['teams'].update_one({ :_id => BSON::ObjectId.from_string(id) }, { "$set" => update_params })
  end

  def self.cachebust_url(url)
    uri = ::URI.parse(url)
    query_args = ::URI.decode_www_form(uri.query || '') << ["ts", Time.now.to_i]
    uri.query = ::URI.encode_www_form(query_args)
    uri.to_s
  end
end
