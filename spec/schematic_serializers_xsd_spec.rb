require "spec_helper"

describe Schematic::Serializers::Xsd do
  before do
    class EmptyModel < ActiveRecord::Base

      def self.columns
        []
      end
    end
  end

  describe ".extend" do
    context "when the model inherits ActiveRecord::Base" do
      subject { EmptyModel }

      it "should allow the model to be extended" do
        lambda {
          subject.class_eval do
          extend Schematic::Serializers::Xsd
          end
        }.should_not raise_error
      end
    end

    context "when the model does not inherit ActiveRecord::Base" do
      subject { Object }

      it "should raise an exception" do
        lambda {
          subject.class_eval do
          extend Schematic::Serializers::Xsd
          end
        }.should raise_error(Schematic::InvalidClass)
      end
    end
  end

  describe ".to_xsd" do
    context "for an empty model with no attributes or validations" do
      subject { EmptyModel.to_xsd }

      it "should return an xsd for an array of the model" do
        xsd = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="empty-models" type="EmptyModels"/>
  <xs:complexType name="EmptyModels">
    <xs:sequence>
      <xs:element name="empty-model" type="EmptyModel" minOccurs="0" maxOccurs="unbounded"/>
    </xs:sequence>
    <xs:attribute name="type" type="xs:string" fixed="array"/>
  </xs:complexType>
  <xs:complexType name="EmptyModel">
    <xs:all>
    </xs:all>
  </xs:complexType>
</xs:schema>
        XML
        subject.should == sanitize_xml(xsd)
      end

    end

    context "for a model with attributes" do

      subject { SomeModel.to_xsd }

      context "for a any attribute" do
        with_model :some_model do
          table :id => false do |t|
            t.float 'some_float'
          end
        end

        it "should define the correct xsd element" do
          xsd = generate_xsd_for_model(SomeModel) do
            <<-XML
              <xs:element name="some-float" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:extension base="xs:float">
                      <xs:attribute name="type" type="xs:string" use="optional"/>
                    </xs:extension>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
            XML
          end

          subject.should == sanitize_xml(xsd)
        end

      end

      describe "additional methods" do
        with_model :some_model do
          table {}
        end

        it "should include the additional method" do
            xsd = generate_xsd_for_model(SomeModel) do
            <<-XML
              <xs:element name="id" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:extension base="xs:integer">
                      <xs:attribute name="type" type="xs:string" use="optional"/>
                    </xs:extension>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
              <xs:element name="foo-bar" minOccurs="0" maxOccurs="1"/>
            XML
          end

          SomeModel.to_xsd(:methods => {:foo_bar => nil}).should == sanitize_xml(xsd)
        end
      end

      describe "nested attributes" do

      end

    end

    context "with a model with validations" do
      context "presence of validation" do
        context "when allow blank is true" do

        end

        context "when allow blank is false" do
        end
      end

      describe "length validation" do

      end

      describe "inclusion validation" do

      end
    end
  end

  private

  def sanitize_xml(xml)
    xml.split("\n").map(&:strip).join("")
  end

  def generate_xsd_for_model(model)
    <<-XML
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
  end
end
