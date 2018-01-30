require 'uri'
require 'rubygems'
require 'bundler/setup'
require 'bjjmapper_api_client'
require_relative '../../database_config'
require_relative '../user_image_uploader'

module UserImageUploaderJob
  @queue = "images"
  @bjjmapper = BJJMapper::ApiClient.new({host: AvatarService::BJJMAPPER_HOST, port: AvatarService::BJJMAPPER_PORT, api_key: ENV['BJJMAPPER_API_KEY']})

  def self.perform(id, path)
    begin
      uploader = UserImageUploader.new(id)
      file = File.open(path, "rb")

      uploader.store!(file)

      self.update_model(id, uploader)
    rescue StandardError => e
      puts "UserImageUploader failed #{e.backtrace}"
      raise e
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

    @bjjmapper.update_user(id, update_params)
  end

  def self.cachebust_url(url)
    uri = ::URI.parse(url)
    query_args = ::URI.decode_www_form(uri.query || '') << ["ts", Time.now.to_i]
    uri.query = ::URI.encode_www_form(query_args)
    uri.to_s
  end
end
