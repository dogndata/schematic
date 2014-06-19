RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'support/database'
require 'support/helpers'
require 'support/with_model'

require 'schematic'
