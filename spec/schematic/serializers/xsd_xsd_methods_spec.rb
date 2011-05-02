require "spec_helper"

describe Schematic::Serializers::Xsd do
  describe ".xsd_methods" do
    context "given a method" do
      with_model :some_model do
        table {}

        model do
          def self.xsd_methods
            {:foo_bar => nil}
          end
        end
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

        sanitize_xml(SomeModel.to_xsd).should eq(xsd)
      end
    end

    context "given a an array of methods" do
      with_model :some_model do
        table {}

        model do
          def self.xsd_methods
            {:foo => [:bar]}
          end
        end
      end

      it "should include the additional methods" do
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
            <xs:element name="foo" minOccurs="0" maxOccurs="1">
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="bar" minOccurs="0" maxOccurs="unbounded"/>
                </xs:sequence>
                <xs:attribute name="type" type="xs:string" fixed="array" use="optional"/>
              </xs:complexType>
            </xs:element>
          XML
        end
        sanitize_xml(SomeModel.to_xsd).should eq(xsd)
      end
    end

    context "given nested methods" do
      with_model :some_model do
        table {}

        model do
          def self.xsd_methods
            { :foo => { :bar => {:baz => nil } } }
          end
        end
      end

      it "should nested the additional methods" do
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
        <xs:element name="foo" minOccurs="0" maxOccurs="1">
          <xs:complexType>
            <xs:all>
              <xs:element name="bar" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:all>
                    <xs:element name="baz" minOccurs="0" maxOccurs="1"/>
                  </xs:all>
                  <xs:attribute name="type" type="xs:string" fixed="array" use="optional"/>
                </xs:complexType>
              </xs:element>
            </xs:all>
            <xs:attribute name="type" type="xs:string" fixed="array" use="optional"/>
          </xs:complexType>
        </xs:element>
          XML
        end

        sanitize_xml(SomeModel.to_xsd).should eq(xsd)
      end
    end
  end
end

