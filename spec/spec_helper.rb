require "active_record"
require "with_model"
require "nokogiri"
require "schematic"

RSpec.configure do |config|
  config.extend WithModel
end

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ":memory:")

def validate_xml_against_xsd(xml, xsd)
  xsd =  Nokogiri::XML::Schema.read_memory(xsd)
  doc = Nokogiri::XML.parse(xml)
  errors = []
  xsd.validate(doc).each do |error|
    errors << error.message
  end
  errors.should == []
end

def validate_xsd(xml)
  xsd_schema_file = File.join(File.dirname(__FILE__), "xsd", "XMLSchema.xsd")
  meta_xsd = Nokogiri::XML::Schema(File.open(xsd_schema_file))

  doc = Nokogiri::XML.parse(xml)
  meta_xsd.validate(doc).each do |error|
    error.message.should be_nil
  end
end

def sanitize_xml(xml)
  xml.split("\n").reject(&:blank?).map(&:strip).join("\n")
end

def generate_xsd_for_model(model)
  output = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="#{model.xsd_element_collection_name}" type="#{model.xsd_type_collection_name}"/>
  <xs:complexType name="#{model.xsd_type_collection_name}">
    <xs:sequence>
      <xs:element name="#{model.xsd_element_name}" type="#{model.xsd_type_name}" minOccurs="0" maxOccurs="unbounded"/>
    </xs:sequence>
    <xs:attribute name="type" type="xs:string" fixed="array"/>
  </xs:complexType>
  <xs:complexType name="#{model.xsd_type_name}">
    <xs:all>
  #{yield}
    </xs:all>
  </xs:complexType>
</xs:schema>
  XML
  sanitize_xml(output)
end
