module Schematic
  module Generator
    class Xsd
      attr_reader :output, :names
      attr_accessor :options

      def initialize(klass, options = {})
        @klass = klass
        @names = Names.new(klass)
        self.options = options
      end

      def options=(hash = {})
        @options = {:generated_types => []}.merge(hash)
        @options[:generated_types] << @klass
        @options
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
        builder.xs :element, "name" => @names.element_collection, "type" => @names.collection_type do |element|
          generate_uniqueness_constraints(element)
        end
      end

      def generate(builder, klass)
        nested_attributes.each do |nested_attribute|
          next if nested_attribute.klass == klass
          next if nested_attribute.klass == klass.superclass
          next if @options && @options[:generated_types] && @options[:generated_types].include?(nested_attribute.klass)
          nested_attribute.klass.generate_xsd(builder, klass, @options)
          @options[:generated_types] << nested_attribute.klass
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
              all.xs :element,
                "name" => nested_attribute_name(nested_attribute.name),
                "type" => nested_attribute.klass.xsd_generator.names.collection_type,
                "minOccurs" => "0",
                "maxOccurs" => "1"
            end

            generate_additional_methods(all, additional_methods)
          end
        end
      end

      def generate_column_elements(builder, additional_methods, ignored_methods)
        @klass.columns.each do |column|
          Column.new(@klass, column, additional_methods, ignored_methods).generate(builder)
        end
      end

      def generate_uniqueness_constraints(builder)
        @klass.columns.each do |column|
           Uniqueness.new(@klass, column).generate(builder)
        end
      end

      def generate_additional_methods(builder, additional_methods)
        additional_methods.each do |method_name, values|
          method_xsd_name = method_name.to_s.dasherize
          if values.is_a?(Array) || values.is_a?(Hash)
            builder.xs :element, "name" => method_xsd_name, "minOccurs" => "0", "maxOccurs" => "1" do |element|
              element.xs :complexType do |complex_type|
                if values.is_a?(Array)
                  complex_type.xs :sequence do |nested_sequence|
                    if values.present?
                      values.each do |value|
                        nested_sequence.xs :element, "name" => value.to_s.dasherize, "minOccurs" => "0", "maxOccurs" => "unbounded"
                      end
                    else
                      nested_sequence.xs :any, "processContents" => "skip", "minOccurs" => "0", "maxOccurs" => "unbounded"
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
            column_klass = Struct.new(:name, :type)
            column = column_klass.new(method_name.to_s, :string)
            Column.new(@klass, column, {}, @klass.xsd_ignore_methods).generate(builder)
          end
        end
      end

      def nested_attributes
        @klass.reflect_on_all_associations.select do |association|
          @klass.instance_methods.include?("#{association.name}_attributes=".to_sym) && association.options[:polymorphic] != true
        end
      end

      def ns(ns, provider, key)
        { "xmlns:#{ns}" => Namespaces::PROVIDERS[provider][key] }
      end

      def nested_attribute_name(name)
        "#{name.to_s.gsub("_", "-").pluralize}-attributes"
      end

    end
  end
end
