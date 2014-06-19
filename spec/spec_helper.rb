require 'active_record'
require 'with_model'
require 'nokogiri'
require 'schematic'

RSpec.configure do |config|
  config.extend WithModel

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.syntax = :expect
  end
end

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

def validate_xml_against_xsd(xml, xsd)
  require 'tempfile'
  tempfile = Tempfile.new('schematic')
  tempfile << xsd
  tempfile.rewind
  xsd =  Nokogiri::XML::Schema(tempfile)
  doc = Nokogiri::XML.parse(xml)
  errors = []
  xsd.validate(doc).each do |error|
    errors << error.message
  end
  expect(errors).to eq([])
ensure
  tempfile.close
end

def validate_xsd(xml)
  xsd_schema_file = File.join(File.dirname(__FILE__), 'xsd', 'XMLSchema.xsd')
  meta_xsd = Nokogiri::XML::Schema(File.open(xsd_schema_file))

  doc = Nokogiri::XML.parse(xml)
  meta_xsd.validate(doc).each do |error|
    expect(error.message).to be_nil
  end
end

def sanitize_xml(xml)
  xml.split("\n").reject(&:blank?).map(&:strip).join("\n")
end

def generate_xsd_for_model(model, header_element = nil)
  xsd_generator = model.schematic_sandbox.xsd_generator
  output = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:complexType name="Integer">
  <xs:simpleContent>
  <xs:extension base="xs:integer">
  <xs:attribute name="type" type="xs:string" use="optional"/>
  <xs:attribute name="nil" type="xs:boolean" use="optional"/>
  </xs:extension>
  </xs:simpleContent>
  </xs:complexType>
  <xs:complexType name="Float">
  <xs:simpleContent>
  <xs:extension base="xs:float">
  <xs:attribute name="type" type="xs:string" use="optional"/>
  <xs:attribute name="nil" type="xs:boolean" use="optional"/>
  </xs:extension>
  </xs:simpleContent>
  </xs:complexType>
  <xs:complexType name="String">
  <xs:simpleContent>
  <xs:extension base="xs:string">
  <xs:attribute name="type" type="xs:string" use="optional"/>
  <xs:attribute name="nil" type="xs:boolean" use="optional"/>
  </xs:extension>
  </xs:simpleContent>
  </xs:complexType>
  <xs:complexType name="Text">
  <xs:simpleContent>
  <xs:extension base="xs:string">
  <xs:attribute name="type" type="xs:string" use="optional"/>
  <xs:attribute name="nil" type="xs:boolean" use="optional"/>
  </xs:extension>
  </xs:simpleContent>
  </xs:complexType>
  <xs:complexType name="DateTime">
  <xs:simpleContent>
  <xs:extension base="xs:dateTime">
  <xs:attribute name="type" type="xs:string" use="optional"/>
  <xs:attribute name="nil" type="xs:boolean" use="optional"/>
  </xs:extension>
  </xs:simpleContent>
  </xs:complexType>
  <xs:complexType name="Date">
  <xs:simpleContent>
  <xs:extension base="xs:date">
  <xs:attribute name="type" type="xs:string" use="optional"/>
  <xs:attribute name="nil" type="xs:boolean" use="optional"/>
  </xs:extension>
  </xs:simpleContent>
  </xs:complexType>
  <xs:complexType name="Boolean">
  <xs:simpleContent>
  <xs:extension base="xs:boolean">
  <xs:attribute name="type" type="xs:string" use="optional"/>
  <xs:attribute name="nil" type="xs:boolean" use="optional"/>
  </xs:extension>
  </xs:simpleContent>
  </xs:complexType>
  <xs:element name="#{xsd_generator.names.element_collection}" type="#{xsd_generator.names.collection_type}">
  #{header_element}
  </xs:element>
  <xs:complexType name="#{xsd_generator.names.collection_type}">
    <xs:sequence>
      <xs:element name="#{xsd_generator.names.element}" type="#{xsd_generator.names.type}" minOccurs="0" maxOccurs="unbounded"/>
    </xs:sequence>
    <xs:attribute name="type" type="xs:string" fixed="array"/>
  </xs:complexType>
  <xs:complexType name="#{xsd_generator.names.type}">
    <xs:all>
  #{yield}
    </xs:all>
  </xs:complexType>
</xs:schema>
  XML
  sanitize_xml(output)
end
