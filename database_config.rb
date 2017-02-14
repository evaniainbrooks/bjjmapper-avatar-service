module AvatarService
  DATABASE_HOST = ENV['RACK_ENV'] == 'production' ? 'services.rollfindr.com' : 'localhost'
  DATABASE_PORT = 27017
  DATABASE_DB = ENV['RACK_ENV'] == 'production' ? 'rollfindr_prod' : 'rollfindr'
  DATABASE_URI = "mongodb://#{DATABASE_HOST}:#{DATABASE_PORT}/#{DATABASE_DB}"
end
