require 'net/http'
require 'tempfile'
require 'uri'

module ImageDownloaderJob
  @queue = "images"

  def self.save_to_tempfile(url)
    STDERR.puts "Downloading #{url}"	

		uri = URI.parse(url)
    resp = Net::HTTP.get_response(uri)
    file = Tempfile.new('avatarsvc', Dir.tmpdir, 'wb+')
    file.binmode
    file.write(resp.body)
    file.flush
    file
	end

  def self.perform(id, url, upload_job_class)
    file = save_to_tempfile(url)
    STDERR.puts "Saved #{url} to #{file.path}"

    Resque.enqueue(upload_job_class.constantize, id, file.path)
  end
end
