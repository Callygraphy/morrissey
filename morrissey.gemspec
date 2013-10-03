$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'morrissey/version'

Gem::Specification.new 'morrissey', Morrissey::VERSION do |s|
  s.description       = "Morrissey is a DSL for quickly creating web applications in Ruby with maximum Smiths references"
  s.summary           = "Sinatra in NHS specs"
  s.authors           = ["Stephen Patrick Morrissey"]
  s.email             = "sinatrarb@googlegroups.com"
  s.homepage          = "http://www.sinatrarb.com/"
  s.files             = `git ls-files`.split("\n") - %w[.gitignore .travis.yml]
  s.test_files        = s.files.select { |p| p =~ /^test\/.*_test.rb/ }
  s.extra_rdoc_files  = s.files.select { |p| p =~ /^README/ } << 'LICENSE'
  s.rdoc_options      = %w[--line-numbers --inline-source --title Morrissey --main README.rdoc --encoding=UTF-8]

  s.add_dependency 'rack', '~> 1.4'
  s.add_dependency 'tilt', '~> 1.3', '>= 1.3.4'
  s.add_dependency 'rack-protection', '~> 1.4'
end
