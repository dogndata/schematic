module Schematic
  module Generator
    class Types
      COMPLEX = {
        :integer => { :complex_type => "Integer", :xsd_type => "xs:integer" },
        :float => { :complex_type => "Float", :xsd_type => "xs:float" },
        :string => { :complex_type => "String", :xsd_type => "xs:string" },
        :text => { :complex_type => "Text", :xsd_type => "xs:string" },
        :datetime => { :complex_type => "DateTime", :xsd_type => "xs:dateTime" },
        :date => { :complex_type => "Date", :xsd_type => "xs:date" },
        :boolean => { :complex_type => "Boolean", :xsd_type => "xs:boolean" },
        :uuid => { :complex_type => "String", :xsd_type => "xs:string" },
      }

      def self.xsd(builder)
        Types::COMPLEX.values.uniq.each do |value|
          complex_type_name = value[:complex_type]
          xsd_type = value[:xsd_type]
          builder.xs :complexType, "name" => complex_type_name do |complex_type|
            complex_type.xs :simpleContent do |simple_content|
              simple_content.xs :extension, "base" => xsd_type do |extension|
                extension.xs :attribute, "name" => "type", "type" => "xs:string", "use" => "optional"
                extension.xs :attribute, "name" => "nil", "type" => "xs:boolean", "use" => "optional"
              end
            end
          end
        end
      end
    end
  end
end
