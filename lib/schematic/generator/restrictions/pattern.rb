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
            if pattern = validator.options[:with]
              value = pattern.source
              value.gsub!(/^(?:\^|\\A|\\a)?/, '')
              value.gsub!(/(?:\$|\\Z|\\z)?$/, '')
              builder.xs(:pattern, "value" => value)
            end
          end
        end
      end
    end
  end
end


