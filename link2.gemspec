# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "link2/version"

Gem::Specification.new do |s|
  s.name        = "link2"
  s.version     = Link2::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jonas Grimfelt"]
  s.email       = ["grimen@gmail.com"]
  s.homepage    = "http://github.com/grimen/#{s.name}"
  s.summary     = %{Generation next link_to-helper for Rails: Spiced with intelligence, and semantic beauty.}
  s.description = s.summary

  s.add_dependency 'activesupport', '>= 2.3.0'
  s.add_dependency 'actionpack', '>= 2.3.0'
  s.add_dependency 'erubis'

  s.add_development_dependency 'bundler', '~> 1.0.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'test-unit', '1.2.3'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'webrat'
  s.add_development_dependency 'leftright'
  s.add_development_dependency 'sqlite3-ruby'
  s.add_development_dependency 'rails', '2.3.12'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-bundler'
  s.add_development_dependency 'guard-test'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end