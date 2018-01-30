require 'uri'
require_relative '../../database_config'
require_relative '../location_image_uploader'

module LocationImageUploaderJob
  @queue = "images"
  @bjjmapper = BJJMapper::ApiClient.new({host: AvatarService::BJJMAPPER_HOST, port: AvatarService::BJJMAPPER_PORT, api_key: ENV['BJJMAPPER_API_KEY']})

  def self.perform(id, path)
    begin
      uploader = LocationImageUploader.new(id)
      file = File.open(path, "rb")

      uploader.store!(file)

      self.update_model(id, uploader)
    rescue StandardError => e
      puts "LocationImageUploader failed #{e.backtrace}"
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

    response = @bjjmapper.update_location(id, update_params)
    STDERR.puts response.inspect
  end

  def self.cachebust_url(url)
    uri = ::URI.parse(url)
    query_args = ::URI.decode_www_form(uri.query || '') << ["ts", Time.now.to_i]
    uri.query = ::URI.encode_www_form(query_args)
    uri.to_s
  end
end
