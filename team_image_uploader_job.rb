require 'mongo'
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
      :image => uploader.url(:small),
      :image_large => uploader.url
    }
    @connection['teams'].update({ :_id => id }, { "$set" => update_params })
  end
end
