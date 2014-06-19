module Schematic
  module Generator
    module Restrictions
      class Numericality < Base
        def generate(builder)
          for_validator ActiveModel::Validations::NumericalityValidator do |validator|
            builder.xs(:pattern, 'value' => '\d+')
          end
        end
      end
    end
  end
end
