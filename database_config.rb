DATABASE_HOST = 'localhost'
DATABASE_PORT = 27017
DATABASE_DB = ENV['RACK_ENV'] == 'production' ? 'rollfindr_prod' : 'mongoid'
DATABASE_QUEUE_DB = 'resque'
