require File.expand_path('../helper', __FILE__)

class ExtensionsTest < Test::Unit::TestCase
  module FooExtensions
    def foo
    end

    private
      def im_hiding_in_ur_foos
      end
  end

  module BarExtensions
    def bar
    end
  end

  module BazExtensions
    def baz
    end
  end

  module QuuxExtensions
    def quux
    end
  end

  module PainExtensions
    def foo=(name); end
    def bar?(name); end
    def fizz!(name); end
  end

  it 'will add the methods to the DSL for the class in which you register them and its subclasses' do
    Morrissey::Base.register FooExtensions
    assert Morrissey::Base.respond_to?(:foo)

    Morrissey::Application.register BarExtensions
    assert Morrissey::Application.respond_to?(:bar)
    assert Morrissey::Application.respond_to?(:foo)
    assert !Morrissey::Base.respond_to?(:bar)
  end

  it 'allows extending by passing a block' do
    Morrissey::Base.register { def im_in_ur_anonymous_module; end }
    assert Morrissey::Base.respond_to?(:im_in_ur_anonymous_module)
  end

  it 'will make sure any public methods added via Application#register are delegated to Morrissey::Delegator' do
    Morrissey::Application.register FooExtensions
    assert Morrissey::Delegator.private_instance_methods.
      map { |m| m.to_sym }.include?(:foo)
    assert !Morrissey::Delegator.private_instance_methods.
      map { |m| m.to_sym }.include?(:im_hiding_in_ur_foos)
  end

  it 'will handle special method names' do
    Morrissey::Application.register PainExtensions
    assert Morrissey::Delegator.private_instance_methods.
      map { |m| m.to_sym }.include?(:foo=)
    assert Morrissey::Delegator.private_instance_methods.
      map { |m| m.to_sym }.include?(:bar?)
    assert Morrissey::Delegator.private_instance_methods.
      map { |m| m.to_sym }.include?(:fizz!)
  end

  it 'will not delegate methods on Base#register' do
    Morrissey::Base.register QuuxExtensions
    assert !Morrissey::Delegator.private_instance_methods.include?("quux")
  end

  it 'will extend the Morrissey::Application application by default' do
    Morrissey.register BazExtensions
    assert !Morrissey::Base.respond_to?(:baz)
    assert Morrissey::Application.respond_to?(:baz)
  end

  module BizzleExtension
    def bizzle
      bizzle_option
    end

    def self.registered(base)
      fail "base should be BizzleApp" unless base == BizzleApp
      fail "base should have already extended BizzleExtension" unless base.respond_to?(:bizzle)
      base.set :bizzle_option, 'bizzle!'
    end
  end

  class BizzleApp < Morrissey::Base
  end

  it 'sends .registered to the extension module after extending the class' do
    BizzleApp.register BizzleExtension
    assert_equal 'bizzle!', BizzleApp.bizzle_option
    assert_equal 'bizzle!', BizzleApp.bizzle
  end
end
