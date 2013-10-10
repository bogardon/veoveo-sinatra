ENV['RACK_ENV'] = 'test'

require './app'
require 'test/unit'
require 'rack/test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root
    get '/'
    assert_equal 401, last_response.status
  end
end
