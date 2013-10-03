require File.expand_path('../helper', __FILE__)

class MorrisseyTest < Test::Unit::TestCase
  it 'creates a new Morrissey::Base subclass on new' do
    app = Morrissey.new { get('/') { 'Hello World' } }
    assert_same Morrissey::Base, app.superclass
  end

  it "responds to #template_cache" do
    assert_kind_of Tilt::Cache, Morrissey::Base.new!.template_cache
  end
end
