module Schematic
  module Generator
    class Column
      attr_accessor :restriction_classes
      class << self
        def restriction_classes
          @restriction_classes ||= [Restrictions::Length, Restrictions::Enumeration, Restrictions::Numericality, Restrictions::Pattern, Restrictions::Custom]
        end
      end

      def initialize(klass, column, additional_methods = {}, ignored_methods = [], required_methods = [])
        @klass = klass
        @column = column
        @additional_methods = additional_methods
        @ignored_methods = ignored_methods
        @required_methods = required_methods
      end

      def generate(builder)
        return if skip_generation?

        builder.xs :element,
          "name" => @column.name.dasherize,
          "minOccurs" => minimum_occurrences_for_column,
          "maxOccurs" => "1" do |field|
          field.xs :complexType do |complex_type|
            complex_type.xs :simpleContent do |simple_content|
              simple_content.xs :restriction, "base" => map_type(@column) do |restriction|
                self.class.restriction_classes.each do |restriction_class|
                  restriction_class.new(@klass, @column).generate(restriction)
                end
              end
            end
          end
        end
      end

      def minimum_occurrences_for_column
        return "1" if @required_methods.include?(@column.name.to_sym)
        return "0" unless @klass.respond_to?(:_validators)
        @klass._validators[@column.name.to_sym].each do |column_validation|
          next unless column_validation.is_a?  ActiveModel::Validations::PresenceValidator
          if column_validation.options[:allow_blank] != true &&
            column_validation.options[:if].nil? &&
            column_validation.options[:unless].nil?

            return "1"
          end
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
