require File.expand_path('../helper', __FILE__)
require 'stringio'

module Rack::Handler
  class Mock
    extend Test::Unit::Assertions

    def self.run(app, options={})
      assert(app < Morrissey::Base)
      assert_equal 9001, options[:Port]
      assert_equal 'foo.local', options[:Host]
      yield new
    end

    def stop
    end
  end

  register 'mock', 'Rack::Handler::Mock'
end

class ServerTest < Test::Unit::TestCase
  setup do
    mock_app do
      set :server, 'mock'
      set :bind, 'foo.local'
      set :port, 9001
    end
    $stderr = StringIO.new
  end

  def teardown
    $stderr = STDERR
  end

  it "locates the appropriate Rack handler and calls ::run" do
    @app.run!
  end

  it "sets options on the app before running" do
    @app.run! :sessions => true
    assert @app.sessions?
  end

  it "falls back on the next server handler when not found" do
    @app.run! :server => %w[foo bar mock]
  end
end
