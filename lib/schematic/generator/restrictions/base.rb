require 'active_support/descendants_tracker'
require 'schematic/generator/column'
require 'schematic/generator/column_validator'

module Schematic
  module Generator
    module Restrictions
      class Base < Schematic::Generator::ColumnValidator
        extend ActiveSupport::DescendantsTracker
      end
    end
  end
end
