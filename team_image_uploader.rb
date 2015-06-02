require 'carrierwave'
require 'carrierwave/processing/mime_types'
require 'fog'
require 'rmagick'
require 'securerandom'
require 'resque'

require './team_image_uploader_job'

CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider                          => 'Google',
    :google_storage_access_key_id      => ENV['GOOGLE_CLIENT_ID'], 
    :google_storage_secret_access_key  => ENV['GOOGLE_CLIENT_SECRET']
  }
  config.fog_directory  = 'bjjmapper'
end

class TeamImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  include CarrierWave::MimeTypes

  LARGE_SIZE = 300
  SMALL_SIZE = 100
  TINY_SIZE  = 50

  LARGE_FILENAME_SUFFIX = "-#{LARGE_SIZE}.png"
  SMALL_FILENAME_SUFFIX = "-#{SMALL_SIZE}.png"
  TINY_FILENAME_SUFFIX = "-#{TINY_SIZE}.png"

  process :resize_to_fill => [LARGE_SIZE, LARGE_SIZE]

  version :small do
    process :resize_to_fill => [SMALL_SIZE, SMALL_SIZE]
    process :set_content_type_png
    convert :png

    def full_filename(for_file=self.file)
      parent_name = super(for_file)
      base_name = parent_name.chomp(LARGE_FILENAME_SUFFIX)
      "#{base_name}#{SMALL_FILENAME_SUFFIX}"
    end

    def full_original_filename
      full_filename(self.file)
    end
  end

  version :tiny do
    process :resize_to_fill => [TINY_SIZE, TINY_SIZE]
    process :set_content_type_png
    convert :png

    def full_filename(for_file=self.file)
      parent_name = super(for_file)
      base_name = parent_name.chomp(LARGE_FILENAME_SUFFIX)
      "#{base_name}#{TINY_FILENAME_SUFFIX}"
    end

    def full_original_filename
      full_filename(self.file)
    end
  end

  storage :fog
  process :set_content_type_png
  convert :png

  def full_filename(for_file=self.file)
    "#{self.model['name'].parameterize}#{LARGE_FILENAME_SUFFIX}"
  end

  def full_original_filename
    full_filename(self.file)
  end

  def set_content_type_png
    self.file.instance_variable_set(:@content_type, "image/png")
  end

  def self.store_async(model, file)
    path = self.copy_upload_to_file(file[:tempfile])
    Resque.enqueue(TeamImageUploaderJob, model, path)
  end

  def store_dir
    "uploads/#{environment}/teams"
  end

  def environment
    ENV['RACK_ENV'] || 'development'
  end

  #def extension_white_list
  #  %w(jpg jpeg gif png)
  #end

  def self.copy_upload_to_file(file)
    random_filename = SecureRandom.hex
    directory = "uploads/"

    path = File.join(directory, random_filename)

    File.open(path, "wb") do |new_file|
      new_file.write file.read
      new_file.close
    end

    return path
  end
end

