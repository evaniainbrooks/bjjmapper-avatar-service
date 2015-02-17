ENV['RACK_ENV'] = 'test'

require './application'
require 'test/unit'
require 'rack/test'

class AvatarServiceTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_avatar_generator_returns_an_image
    get "/100x100/Marcelo%20Garcia/image.png"
    assert last_response.ok?
    assert last_response.headers['Content-Length'].to_i > 100
    assert_equal last_response.headers['Content-Type'], "image/png"
  end


  def test_returns_400_with_missing_file_argument
    post "/upload/teams/54ab7538bc80674621000000/async"
    assert !last_response.ok?
    assert_equal last_response.status, 400
  end

  def test_returns_404_with_missing_model
    post "/upload/teams/54ab7538bc80674621000000/async", { :file => { :tempfile => "bogus" } }
    assert !last_response.ok?
    assert_equal last_response.status, 404
  end
end
