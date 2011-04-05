module Schematic
  module Serializers
    module Xsd
      class << self
        def extended(klass)
          raise InvalidClass unless klass.ancestors.include?(ActiveRecord::Base)
        end
      end

      def to_xsd(options = {})
        output = ""
        builder = Builder::XmlMarkup.new(:target => output)
        builder.instruct!
        builder.xs :schema, "xmlns:xs" => "http://www.w3.org/2001/XMLSchema" do |schema|
          schema.xs :element, "name" => xsd_element_collection_name, "type" => xsd_type_collection_name
          generate_xsd(options, schema, self)
        end
        output
      end

      def map_column_type_to_xsd_type(column)
        {
          :integer => "xs:integer",
          :float => "xs:float",
          :string => "xs:string",
          :text => "xs:string",
          :datetime => "xs:dateTime",
          :date => "xs:date",
          :boolean => "xs:boolean"
        }[column.type]
      end

      def xsd_minimum_occurrences_for_column(column)
        self._validators[column.name.to_sym].each do |column_validation|
          next unless column_validation.is_a?  ActiveModel::Validations::PresenceValidator
          return "1" if column_validation.options[:allow_blank] != true && column_validation.options[:if].nil?
        end
        "0"
      end

      def xsd_element_collection_name
        xsd_element_name.pluralize
      end

      def xsd_type_collection_name
        xsd_type_name.pluralize
      end

      def xsd_type_name
        self.name.demodulize
      end

      def xsd_element_name
        xsd_type_name.underscore.dasherize
      end

      def generate_xsd(options, builder, klass)
        xsd_nested_attributes.each do |nested_attribute|
          next if nested_attribute.klass == klass || nested_attribute.klass == klass.superclass

          nested_attribute.klass.generate_xsd(options, builder, klass)
        end

        generate_xsd_complex_type_for_collection(builder)
        generate_xsd_complex_type_for_model(options, builder)
      end

      private

      def generate_xsd_complex_type_for_collection(builder)
        builder.xs :complexType, "name" => xsd_type_collection_name do |complex_type|
          complex_type.xs :sequence do |sequence|
            sequence.xs :element, "name" => xsd_element_name, "type" => xsd_type_name, "minOccurs" => "0", "maxOccurs" => "unbounded"
          end
          complex_type.xs :attribute, "name" => "type", "type" => "xs:string", "fixed" => "array"
        end
      end

      def generate_xsd_complex_type_for_model(options, builder)
        builder.xs :complexType, "name" => xsd_type_name do |complex_type|
          additional_methods = xsd_methods.merge(options[:methods] || {})
          ignored_methods = xsd_ignore_methods | (options[:exclude] || [])
          complex_type.xs :all do |all|
            generate_xsd_column_elements(all, additional_methods, ignored_methods)

            xsd_nested_attributes.each do |nested_attribute|
              all.xs :element, "name" => "#{nested_attribute.name.to_s.dasherize}-attributes", "type" => nested_attribute.klass.xsd_type_collection_name, "minOccurs" => "0", "maxOccurs" => "1"
            end

            generate_xsd_additional_methods(all, additional_methods)
          end
        end
      end

      def generate_xsd_column_elements(builder, additional_methods, ignored_methods)
        xsd_columns.each do |column|
          next if additional_methods.keys.map(&:to_s).include?(column.name) || ignored_methods.map(&:to_s).include?(column.name)

          builder.xs :element, "name" => column.name.dasherize, "minOccurs" => xsd_minimum_occurrences_for_column(column), "maxOccurs" => "1" do |field|
            field.xs :complexType do |complex_type|
              complex_type.xs :simpleContent do |simple_content|
                simple_content.xs :extension, "base" => map_column_type_to_xsd_type(column) do |extension|
                  extension.xs :attribute, "name" => "type", "type" => "xs:string", "use" => "optional"
                end
              end
            end
          end
        end
      end

      def generate_xsd_additional_methods(builder, additional_methods)
        additional_methods.each do |method_name, values|
          method_xsd_name = method_name.to_s.dasherize
          if values.present?
            builder.xs :element, "name" => method_xsd_name, "minOccurs" => "0", "maxOccurs" => "1" do |element|
              element.xs :complexType do |complex_type|
                complex_type.xs :all do |nested_all|
                  values.each do |value|
                    nested_all.xs :element, "name" => value.to_s.dasherize, "minOccurs" => "0"
                  end
                end
                complex_type.xs :attribute, "name" => "type", "type" => "xs:string", "fixed" => "array", "use" => "optional"
              end
            end
          else
            builder.xs :element, "name" => method_xsd_name, "minOccurs" => "0", "maxOccurs" => "1"
          end
        end
      end

      def xsd_methods
        {}
      end

      def xsd_ignore_methods
        []
      end

      def xsd_nested_attributes
        self.reflect_on_all_associations.select do |association|
          self.instance_methods.include?("#{association.name}_attributes=".to_sym) && association.options[:polymorphic] != true
        end
      end

      def xsd_columns
        self.columns
      end


    end
  end
end
