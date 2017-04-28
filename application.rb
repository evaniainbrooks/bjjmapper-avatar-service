require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json/ext'

require 'resque'

require_relative 'database_config'
require_relative 'app/avatar_generator'
require_relative 'app/team_image_uploader'
require_relative 'app/user_image_uploader'
require_relative 'app/location_image_uploader'
require_relative 'app/jobs/image_downloader_job'

module AvatarService
  WORKERS = ['images_queue_worker']

  class Application < Sinatra::Application
    configure do
      set :app_file, __FILE__
      set :bind, '0.0.0.0'
      set :port, ENV['PORT']

      Resque.redis = Redis.new(host: DATABASE_HOST, password: ENV['REDIS_PASS'])
    end

    post '/upload/users/:user_id/async' do
      content_type :json

      unless params[:file] && params[:file][:tempfile]
        STDERR.puts "Missing file argument, returning 400"
        halt 400
      end

      UserImageUploader.store_async(params[:user_id], params[:file])

      status 202
    end

    post '/upload/teams/:team_id/async' do
      content_type :json

      unless params[:file] && params[:file][:tempfile]
        STDERR.puts "Missing file argument, returning 400"
        halt 400
      end

      TeamImageUploader.store_async(params[:team_id], params[:file])

      status 202
    end
    
    post '/upload/locations/:location_id/async' do
      content_type :json

      unless params[:file] && params[:file][:tempfile]
        STDERR.puts "Missing file argument, returning 400"
        halt 400
      end

      LocationImageUploader.store_async(params[:location_id], params[:file])

      status 202
    end

    post '/upload/locations/:location_id/url' do
      content_type :json

      puts "Parsing post body"
      request.body.rewind
      post_body = JSON.parse(request.body.read)

      unless post_body['url']
        STDERR.puts "Missing url argument, returning 400"
        halt 400
      end

      puts "Enqueuing download job for #{post_body['url']}"
      Resque.enqueue(ImageDownloaderJob, params[:location_id], post_body['url'], LocationImageUploaderJob.to_s)

      status 202
    end

    get '/:width_height/:name/image.png' do
      content_type 'image/png'

      name = (params[:name] || '?')
      width, height = (params[:width_height] || '100x100').split('x')
      options = {
        name: name,
        width: width.to_i,
        height: height.to_i,
        format: 'png'
      }

      AvatarGenerator.avatar_for(options)
    end
  end
end
