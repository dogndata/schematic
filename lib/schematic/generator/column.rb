module Schematic
  module Generator
    class Column

      def initialize(klass, column, additional_methods = {}, ignored_methods = {})
        @klass = klass
        @column = column
        @additional_methods = additional_methods
        @ignored_methods = ignored_methods
      end

      def generate(builder)
        return if skip_generation?

        builder.xs :element, "name" => @column.name.dasherize, "minOccurs" => minimum_occurrences_for_column, "maxOccurs" => "1" do |field|
          field.xs :complexType do |complex_type|
            complex_type.xs :simpleContent do |simple_content|
              simple_content.xs :restriction, "base" => map_type(@column) do |restriction|
                Restrictions::Length.new(@klass, @column).generate(restriction)
                Restrictions::Enumeration.new(@klass, @column).generate(restriction)
                Restrictions::Pattern.new(@klass, @column).generate(restriction)
              end
            end
          end
        end
      end

      def minimum_occurrences_for_column
        @klass._validators[@column.name.to_sym].each do |column_validation|
          next unless column_validation.is_a?  ActiveModel::Validations::PresenceValidator
          return "1" if column_validation.options[:allow_blank] != true && column_validation.options[:if].nil?
        end
        "0"
      end


      def map_type(column)
        Types::COMPLEX[column.type][:complex_type]
      end

      def skip_generation?
        @additional_methods.keys.map(&:to_s).include?(@column.name) ||
          @ignored_methods.map(&:to_s).include?(@column.name)
      end
    end
  end
end
