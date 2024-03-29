ENV['RACK_ENV'] = 'test'
Encoding.default_external = "UTF-8" if defined? Encoding

RUBY_ENGINE = 'ruby' unless defined? RUBY_ENGINE

begin
  require 'rack'
rescue LoadError
  require 'rubygems'
  require 'rack'
end

testdir = File.dirname(__FILE__)
$LOAD_PATH.unshift testdir unless $LOAD_PATH.include?(testdir)

libdir = File.dirname(File.dirname(__FILE__)) + '/lib'
$LOAD_PATH.unshift libdir unless $LOAD_PATH.include?(libdir)

require 'contest'
require 'rack/test'
require 'morrissey/base'

class Morrissey::Base
  # Allow assertions in request context
  include Test::Unit::Assertions
end

class Rack::Builder
  def include?(middleware)
    @ins.any? { |m| p m ; middleware === m }
  end
end

Morrissey::Base.set :environment, :test

class Test::Unit::TestCase
  include Rack::Test::Methods

  class << self
    alias_method :it, :test
    alias_method :section, :context
  end

  def self.example(desc = nil, &block)
    @example_count = 0 unless instance_variable_defined? :@example_count
    @example_count += 1
    it(desc || "Example #{@example_count}", &block)
  end

  alias_method :response, :last_response

  setup do
    Morrissey::Base.set :environment, :test
  end

  # Sets up a Morrissey::Base subclass defined with the block
  # given. Used in setup or individual spec methods to establish
  # the application.
  def mock_app(base=Morrissey::Base, &block)
    @app = Morrissey.new(base, &block)
  end

  def app
    Rack::Lint.new(@app)
  end

  def body
    response.body.to_s
  end

  def assert_body(value)
    if value.respond_to? :to_str
      assert_equal value.lstrip.gsub(/\s*\n\s*/, ""), body.lstrip.gsub(/\s*\n\s*/, "")
    else
      assert_match value, body
    end
  end

  def assert_status(expected)
    assert_equal Integer(expected), Integer(status)
  end

  def assert_like(a,b)
    pattern = /id=['"][^"']*["']|\s+/
    assert_equal a.strip.gsub(pattern, ""), b.strip.gsub(pattern, "")
  end

  def assert_include(str, substr)
    assert str.include?(substr), "expected #{str.inspect} to include #{substr.inspect}"
  end

  def options(uri, params = {}, env = {}, &block)
    request(uri, env.merge(:method => "OPTIONS", :params => params), &block)
  end

  def patch(uri, params = {}, env = {}, &block)
    request(uri, env.merge(:method => "PATCH", :params => params), &block)
  end

  def link(uri, params = {}, env = {}, &block)
    request(uri, env.merge(:method => "LINK", :params => params), &block)
  end

  def unlink(uri, params = {}, env = {}, &block)
    request(uri, env.merge(:method => "UNLINK", :params => params), &block)
  end

  # Delegate other missing methods to response.
  def method_missing(name, *args, &block)
    if response && response.respond_to?(name)
      response.send(name, *args, &block)
    else
      super
    end
  rescue Rack::Test::Error
    super
  end

  # Also check response since we delegate there.
  def respond_to?(symbol, include_private=false)
    super || (response && response.respond_to?(symbol, include_private))
  end

  # Do not output warnings for the duration of the block.
  def silence_warnings
    $VERBOSE, v = nil, $VERBOSE
    yield
  ensure
    $VERBOSE = v
  end
end
