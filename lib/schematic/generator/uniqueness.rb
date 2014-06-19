module Schematic
  module Generator
    class Uniqueness < ColumnValidator

      def generate(builder)
        for_validator ActiveRecord::Validations::UniquenessValidator do |validator|
          unique_name = validator.attributes.first.to_s.dasherize
          additional_fields = (Array.wrap(validator.options[:scope]) || []).map(&:to_s).map(&:dasherize)

          names = Schematic::Generator::Names.new(@klass)
          builder.xs :unique, 'name' => "#{unique_name}-must-be-unique" do |unique|
            unique.xs :selector, 'xpath' => "./#{names.element}"
            unique.xs :field, 'xpath' => unique_name
            additional_fields.each do |additional_field|
              unique.xs :field, 'xpath' => additional_field
            end
          end
        end
      end
    end
  end
end



