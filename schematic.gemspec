# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'schematic/version'

Gem::Specification.new do |s|
  s.name        = 'schematic'
  s.version     = Schematic::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Case Commons, LLC']
  s.email       = ['casecommons-dev@googlegroups.com']
  s.homepage    = 'https://github.com/Casecommons/schematic'
  s.summary     = %q{Automatic XSD generation from ActiveRecord models}
  s.description = %q{Automatic XSD generation from ActiveRecord models}

  s.rubyforge_project = 'schematic'

  s.add_dependency('activerecord', '~> 4.0')
  s.add_dependency('builder')
  s.add_development_dependency('rspec', '~> 2.14')
  s.add_development_dependency('rspec-rails')
  s.add_development_dependency('with_model', '>= 0.2.4')
  s.add_development_dependency('nokogiri')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('autotest')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
