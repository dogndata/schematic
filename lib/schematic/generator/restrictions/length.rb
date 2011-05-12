module Schematic
  module Generator
    module Restrictions
      class Length
        def initialize(klass, column)
          @klass = klass
          @column = column
        end

        def generate(builder)
          @klass._validators[@column.name.to_sym].each do |column_validation|
            next unless column_validation.is_a?  ActiveModel::Validations::LengthValidator
            next unless column_validation.options[:if].nil?
            builder.xs(:maxLength, "value" => column_validation.options[:maximum]) if column_validation.options[:maximum]
            builder.xs(:minLength, "value" => column_validation.options[:minimum]) if column_validation.options[:minimum]
            return
          end
        end
      end
    end
  end
end
