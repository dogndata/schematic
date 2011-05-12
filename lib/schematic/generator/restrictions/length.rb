module Schematic
  module Generator
    module Restrictions
      class Length < Base
        def generate(builder)
          for_validator ActiveModel::Validations::LengthValidator do |validator|
            builder.xs(:maxLength, "value" => validator.options[:maximum]) if validator.options[:maximum]
            builder.xs(:minLength, "value" => validator.options[:minimum]) if validator.options[:minimum]
          end
        end
      end
    end
  end
end
