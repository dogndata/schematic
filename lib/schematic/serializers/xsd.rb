module Schematic
  module Serializers
    module Xsd
      class << self
        def extended(klass)
          raise InvalidClass unless klass.ancestors.include?(ActiveRecord::Base)
        end
      end

      def to_xsd(options = {}, builder = nil)
        if builder.nil?
          output = ""
          builder = Builder::XmlMarkup.new(:target => output)
          builder.instruct!
          builder.xs :schema, "xmlns:xs" => "http://www.w3.org/2001/XMLSchema" do |schema|
            schema.xs :element, "name" => xsd_element_collection_name, "type" => xsd_type_collection_name
            self.to_xsd(options, schema)
          end
          output
        else
          xsd_nested_attributes.each do |nested_attribute|
            nested_attribute.klass.to_xsd(options, builder)
          end
          builder.xs :complexType, "name" => xsd_type_collection_name do |complex_type|
            complex_type.xs :sequence do |sequence|
              sequence.xs :element, "name" => xsd_element_name, "type" => xsd_type_name, "minOccurs" => "0", "maxOccurs" => "unbounded"
            end
            complex_type.xs :attribute, "name" => "type", "type" => "xs:string", "fixed" => "array"
          end
          builder.xs :complexType, "name" => xsd_type_name do |complex_type|
            additional_methods = xsd_methods.merge(options[:methods] || {})
            complex_type.xs :all do |all|
              xsd_columns.each do |column|
                next if additional_methods.keys.map(&:to_s).include?(column.name)

                all.xs :element, "name" => column.name.dasherize, "minOccurs" => "0", "maxOccurs" => "1" do |field|
                  field.xs :complexType do |complex_type|
                    complex_type.xs :simpleContent do |simple_content|
                      simple_content.xs :extension, "base" => map_column_type_to_xsd_type(column) do |extension|
                        extension.xs :attribute, "name" => "type", "type" => "xs:string", "use" => "optional"
                      end
                    end
                  end
                end
              end
              xsd_nested_attributes.each do |nested_attribute|
                all.xs :element, "name" => "#{nested_attribute.name.to_s.dasherize}-attributes", "type" => nested_attribute.klass.xsd_type_collection_name, "minOccurs" => "0", "maxOccurs" => "1"
              end
              additional_methods.each do |method_name, values|
                method_xsd_name = method_name.to_s.dasherize
                if values.present?
                  all.xs :element, "name" => method_xsd_name, "minOccurs" => "0", "maxOccurs" => "1" do |element|
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
                  all.xs :element, "name" => method_xsd_name, "minOccurs" => "0", "maxOccurs" => "1"
                end
              end
            end
          end
          builder
        end
      end

      def xsd_methods
        {}
      end

      def xsd_nested_attributes
        self.reflect_on_all_associations.select do |association|
          self.instance_methods.include?("#{association.name}_attributes=".to_sym) && association.options[:polymorphic] != true
        end
      end

      def xsd_columns
        self.columns
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

      def xsd_type_name
        self.name
      end

      def xsd_type_collection_name
        xsd_type_name.pluralize
      end

      def xsd_element_name
        self.name.underscore.dasherize
      end

      def xsd_element_collection_name
        xsd_element_name.pluralize
      end
    end
  end
end
