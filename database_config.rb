module AvatarService
  DATABASE_HOST = ENV['RACK_ENV'] == 'production' ? 'services.rollfindr.com' : 'localhost'
  DATABASE_PORT = 27017
  BJJMAPPER_HOST = 'localhost'
  BJJMAPPER_PORT = 80
end
