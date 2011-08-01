module Schematic
  module Generator
    class ColumnValidator
      attr_reader :klass, :column

      def initialize(klass, column)
        @klass = klass
        @column = column
      end

      def for_validator(validator_klass)
        validators_for_column.each do |column_validation|
          next unless column_validation.is_a? validator_klass
          has_conditional_proc = !column_validation.options[:if].nil? || !column_validation.options[:unless].nil?
          force_inclusion = column_validation.options[:xsd] && column_validation.options[:xsd][:include]
          next if has_conditional_proc && !force_inclusion
          yield(column_validation)
          return
        end
      end

      def validators_for_column
        klass._validators[column.name.to_sym]
      end
    end
  end
end
