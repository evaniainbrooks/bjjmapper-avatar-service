require 'resque'
require 'mongo'
require './database_config'
require './team_image_uploader_job'

include Mongo

WAIT_INTERVAL = 10.0
RESQUE_IMAGES_QUEUE = "images"

Resque.mongo = MongoClient.new(DATABASE_HOST , DATABASE_PORT).db(DATABASE_QUEUE_DB)

STDOUT.puts "Starting images queue worker on #{DATABASE_HOST}:#{DATABASE_PORT}/#{DATABASE_QUEUE_DB}"

worker = Resque::Worker.new(RESQUE_IMAGES_QUEUE)
worker.verbose = worker.very_verbose = true
worker.work(WAIT_INTERVAL)

