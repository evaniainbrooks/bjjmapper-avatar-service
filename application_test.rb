ENV['RACK_ENV'] = 'test'

require './application'
require 'test/unit'
require 'rack/test'

class AvatarServiceTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_returns_an_image
    get "/100x100/Marcelo%20Garcia/image.png"
    assert last_response.ok?
    assert last_response.headers['Content-Length'].to_i > 100
    assert_equal last_response.headers['Content-Type'], "image/png"
  end
end
