source 'https://rubygems.org'

# Specify your gem's dependencies in schematic.gemspec
gemspec

gem 'activerecord', :github => 'rails', :branch => ENV['ACTIVE_RECORD_BRANCH'] if ENV['ACTIVE_RECORD_BRANCH']
gem 'activerecord', ENV['ACTIVE_RECORD_VERSION'] if ENV['ACTIVE_RECORD_VERSION']
gem 'activerecord-jdbcsqlite3-adapter', :platforms => :jruby
gem 'sqlite3', '1.3.13', :platforms => :ruby
