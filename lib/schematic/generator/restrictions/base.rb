module Schematic
  module Generator
    module Restrictions
      class Base
        def initialize(klass, column)
          @klass = klass
          @column = column
        end

        def for_validator(validator_klass)
          validators_for_column.each do |column_validation|
            next unless column_validation.is_a? validator_klass
            next unless column_validation.options[:if].nil? || column_validation.options[:unless].nil?
            yield(column_validation)
            return
          end
        end

        def validators_for_column
          @klass._validators[@column.name.to_sym]
        end

      end
    end
  end
end


