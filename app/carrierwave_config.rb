require 'carrierwave'
require 'fog'

CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider                          => 'Google',
    :google_storage_access_key_id      => ENV['GOOGLE_CLIENT_ID'],
    :google_storage_secret_access_key  => ENV['GOOGLE_CLIENT_SECRET']
  }
  config.fog_directory  = 'bjjmapper'
end

