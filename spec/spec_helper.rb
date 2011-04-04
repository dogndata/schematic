require "active_record"
require "with_model"
require "nokogiri"
require "schematic"

RSpec.configure do |config|
  config.extend WithModel
end

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ":memory:")
