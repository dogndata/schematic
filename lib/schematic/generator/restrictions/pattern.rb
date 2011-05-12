module Schematic
  module Generator
    module Restrictions
      class Pattern < Base
        def initialize(klass, column)
          @klass = klass
          @column = column
        end

        def generate(builder)
          for_validator ActiveModel::Validations::FormatValidator do |validator|
            builder.xs(:pattern, "value" => validator.options[:with].source) if validator.options[:with]
          end
        end
      end
    end
  end
end


