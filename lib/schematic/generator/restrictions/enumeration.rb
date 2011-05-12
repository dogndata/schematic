module Schematic
  module Generator
    module Restrictions
      class Enumeration < Base
        def initialize(klass, column)
          @klass = klass
          @column = column
        end

        def generate(builder)
          for_validator ActiveModel::Validations::InclusionValidator do |validator|
            validator.options[:in].each do |value|
              builder.xs(:enumeration, "value" => value)
            end
          end
        end
      end
    end
  end
end

