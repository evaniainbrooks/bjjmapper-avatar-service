require 'dotenv'
Dotenv.load

require 'resque'
require_relative 'database_config'
require_relative 'team_image_uploader_job'
require_relative 'user_image_uploader_job'
require_relative 'location_image_uploader_job'

WAIT_INTERVAL = 10.0
RESQUE_IMAGES_QUEUE = "images"

Resque.redis = Redis.new(host: DATABASE_HOST, password: ENV['REDIS_PASS'])

STDOUT.puts "Starting images queue worker on #{Resque.redis.inspect}"

worker = Resque::Worker.new(RESQUE_IMAGES_QUEUE)
worker.verbose = worker.very_verbose = true
worker.work(WAIT_INTERVAL)

