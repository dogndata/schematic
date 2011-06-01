module Schematic
  module Generator
    module Restrictions
      class Pattern < Base
        def generate(builder)
          for_validator ActiveModel::Validations::FormatValidator do |validator|
            if pattern = validator.options[:with]
              value = pattern.source
              value.gsub!(/^(?:\^|\\A|\\a)?/, '')
              value.gsub!(/(?:\$|\\Z|\\z)?$/, '')
              value.gsub!(/\\\$/, '$')
              value.gsub!(/\(\?:/, '(')
              builder.xs(:pattern, "value" => value)
            end
          end
        end
      end
    end
  end
end


