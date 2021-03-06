# spec/spec_helper.rb
require 'rack/test'
require 'rspec'
require 'dotenv'

Dotenv.load

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../application.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() AvatarService::Application end
end

# For RSpec 2.x and 3.x
RSpec.configure do |c|
  c.expect_with(:rspec) { |o| o.syntax = :should }
  c.include RSpecMixin
  c.order = "random"
end
