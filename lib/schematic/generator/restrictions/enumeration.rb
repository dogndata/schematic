module Schematic
  module Generator
    module Restrictions
      class Enumeration < Base
        def generate(builder)
          for_validator ActiveModel::Validations::InclusionValidator do |validator|
            next if column.type == :boolean
            next if validator.options[:in].respond_to?(:call)
            validator.options[:in].each do |value|
              builder.xs(:enumeration, "value" => value)
            end
          end
          enumeration_method = "xsd_#{column.name}_enumeration_restrictions".to_sym
          if klass.respond_to? enumeration_method
            klass.send(enumeration_method).each do |enumeration|
              builder.xs(:enumeration, "value" => enumeration)
            end
          end
        end
      end
    end
  end
end

