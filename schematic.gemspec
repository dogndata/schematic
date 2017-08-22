# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'schematic/version'

Gem::Specification.new do |spec|
  spec.name        = 'schematic'
  spec.version     = Schematic::VERSION
  spec.authors     = ['Case Commons, LLC']
  spec.email       = ['casecommons-dev@googlegroups.com', 'andrew@johnandrewmarshall.com']
  spec.homepage    = 'https://github.com/Casecommons/schematic'
  spec.summary     = %q{Automatic XSD generation from ActiveRecord models}
  spec.description = spec.summary
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~> 4.0'
  spec.add_dependency 'builder'

  spec.add_development_dependency 'nokogiri'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'with_model', '~> 1.0'
end
