require '.env'
Dotenv.load

require 'resque'
require 'mongo'
require_relative 'database_config'
require_relative 'team_image_uploader_job'
require_relative 'user_image_uploader_job'

include Mongo

WAIT_INTERVAL = 10.0
RESQUE_IMAGES_QUEUE = "images"

Resque.mongo = MongoClient.new(AvatarService::DATABASE_HOST , AvatarService::DATABASE_PORT).db(AvatarService::DATABASE_QUEUE_DB)

STDOUT.puts "Starting images queue worker on #{AvatarService::DATABASE_HOST}:#{AvatarService::DATABASE_PORT}/#{AvatarService::DATABASE_QUEUE_DB}"

worker = Resque::Worker.new(RESQUE_IMAGES_QUEUE)
worker.verbose = worker.very_verbose = true
worker.work(WAIT_INTERVAL)

