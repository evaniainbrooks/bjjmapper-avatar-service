require 'carrierwave'
require 'carrierwave/processing/mime_types'
require 'fog'
require 'rmagick'
require 'securerandom'
require 'resque'

require_relative 'carrierwave_config'
require_relative './jobs/location_image_uploader_job'

class LocationImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  include CarrierWave::MimeTypes

  LARGE_SIZE = 300
  SMALL_SIZE = 100
  TINY_SIZE  = 50

  LARGE_FILENAME_SUFFIX = "-#{LARGE_SIZE}.png"
  SMALL_FILENAME_SUFFIX = "-#{SMALL_SIZE}.png"
  TINY_FILENAME_SUFFIX = "-#{TINY_SIZE}.png"

  process :resize_to_limit => [LARGE_SIZE, nil]

  version :small do
    process :resize_to_limit => [SMALL_SIZE, nil]
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
    process :resize_to_limit => [TINY_SIZE, nil]
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
    "#{self.model.parameterize}#{LARGE_FILENAME_SUFFIX}"
  end

  def full_original_filename
    full_filename(self.file)
  end

  def set_content_type_png
    self.file.instance_variable_set(:@content_type, "image/png")
  end

  def self.store_async(id, file)
    path = self.copy_upload_to_file(file[:tempfile])
    Resque.enqueue(LocationImageUploaderJob, id, path)
  end

  def store_dir
    "uploads/#{environment}/locations"
  end

  def environment
    ENV['RACK_ENV'] || 'development'
  end

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

