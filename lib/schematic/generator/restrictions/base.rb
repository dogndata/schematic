module Schematic
  module Generator
    module Restrictions
      class Base
        def initialize(klass, column)
          @klass = klass
          @column = column
        end

        def for_validator(validator_klass)
          @klass._validators[@column.name.to_sym].each do |column_validation|
            next unless column_validation.is_a? validator_klass
            next unless column_validation.options[:if].nil?
            yield(column_validation)
            return
          end
        end

      end
    end
  end
end


