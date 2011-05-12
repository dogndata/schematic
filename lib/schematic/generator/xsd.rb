module Schematic
  module Generator
    class Xsd
      attr_reader :output, :names
      attr_accessor :options

      def initialize(klass, options = {})
        @klass = klass
        @names = Names.new(klass)
        @options = options
      end

      def header(builder)
        builder.instruct!
      end

      def schema(builder)
        builder.xs :schema, ns("xs", :w3, :schema) do |schema|
          Types.xsd(schema)
          element_for_klass(schema)
          generate(schema, @klass)
        end
      end

      def element_for_klass(builder)
        builder.xs :element, "name" => @names.element_collection, "type" => @names.collection_type
      end

      def generate(builder, klass)
        nested_attributes.each do |nested_attribute|
          next if nested_attribute.klass == klass || nested_attribute.klass == klass.superclass

          nested_attribute.klass.generate_xsd(builder, klass, @options)
        end

        generate_complex_type_for_collection(builder)
        generate_complex_type_for_model(builder)
      end

      def generate_complex_type_for_collection(builder)
        builder.xs :complexType, "name" => @names.collection_type do |complex_type|
          complex_type.xs :sequence do |sequence|
            sequence.xs :element, "name" => @names.element, "type" => @names.type, "minOccurs" => "0", "maxOccurs" => "unbounded"
          end
          complex_type.xs :attribute, "name" => "type", "type" => "xs:string", "fixed" => "array"
        end
      end

      def generate_complex_type_for_model(builder)
        builder.xs :complexType, "name" => @names.type do |complex_type|
          additional_methods = @klass.xsd_methods.merge(@options[:methods] || {})
          ignored_methods = @klass.xsd_ignore_methods | (@options[:exclude] || [])
          complex_type.xs :all do |all|
            generate_column_elements(all, additional_methods, ignored_methods)

            nested_attributes.each do |nested_attribute|
              all.xs :element, "name" => "#{nested_attribute.name.to_s.dasherize}-attributes", "type" => nested_attribute.klass.xsd_generator.names.collection_type, "minOccurs" => "0", "maxOccurs" => "1"
            end

            generate_additional_methods(all, additional_methods)
          end
        end
      end

      def generate_column_elements(builder, additional_methods, ignored_methods)
        @klass.columns.each do |column|
          next if additional_methods.keys.map(&:to_s).include?(column.name) || ignored_methods.map(&:to_s).include?(column.name)

          builder.xs :element, "name" => column.name.dasherize, "minOccurs" => minimum_occurrences_for_column(column), "maxOccurs" => "1" do |field|
            field.xs :complexType do |complex_type|
              complex_type.xs :simpleContent do |simple_content|
                simple_content.xs :restriction, "base" => map_type(column) do |restriction|
                  generate_length_restriction_for_column(restriction, column)
                end
              end
            end
          end
        end
      end

      def generate_length_restriction_for_column(builder, column)
        @klass._validators[column.name.to_sym].each do |column_validation|
          next unless column_validation.is_a?  ActiveModel::Validations::LengthValidator
          next unless column_validation.options[:if].nil?
          builder.xs(:maxLength, "value" => column_validation.options[:maximum]) if column_validation.options[:maximum]
          builder.xs(:minLength, "value" => column_validation.options[:minimum]) if column_validation.options[:minimum]
          return
        end
      end

      def generate_additional_methods(builder, additional_methods)
        additional_methods.each do |method_name, values|
          method_xsd_name = method_name.to_s.dasherize
          if values.present?
            builder.xs :element, "name" => method_xsd_name, "minOccurs" => "0", "maxOccurs" => "1" do |element|
              element.xs :complexType do |complex_type|
                if values.is_a?(Array)
                  complex_type.xs :sequence do |nested_sequence|
                    values.each do |value|
                      nested_sequence.xs :element, "name" => value.to_s.dasherize, "minOccurs" => "0", "maxOccurs" => "unbounded"
                    end
                  end
                elsif values.is_a?(Hash)
                  complex_type.xs :all do |nested_all|
                    generate_additional_methods(nested_all, values)
                  end
                else
                  raise "Additional methods must be a hash of hashes or hash of arrays"
                end
                complex_type.xs :attribute, "name" => "type", "type" => "xs:string", "fixed" => "array", "use" => "optional"
              end
            end
          else
            builder.xs :element, "name" => method_xsd_name, "minOccurs" => "0", "maxOccurs" => "1"
          end
        end
      end

      def minimum_occurrences_for_column(column)
        @klass._validators[column.name.to_sym].each do |column_validation|
          next unless column_validation.is_a?  ActiveModel::Validations::PresenceValidator
          return "1" if column_validation.options[:allow_blank] != true && column_validation.options[:if].nil?
        end
        "0"
      end

      def nested_attributes
        @klass.reflect_on_all_associations.select do |association|
          @klass.instance_methods.include?("#{association.name}_attributes=".to_sym) && association.options[:polymorphic] != true
        end
      end

      def map_type(column)
        Types::COMPLEX[column.type][:complex_type]
      end

      def ns(ns, provider, key)
        { "xmlns:#{ns}" => Namespaces::PROVIDERS[provider][key] }
      end

    end
  end
end
