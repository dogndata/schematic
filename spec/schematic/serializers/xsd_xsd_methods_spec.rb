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
              <xs:restriction base="Integer">
              </xs:restriction>
            </xs:simpleContent>
          </xs:complexType>
        </xs:element>
        <xs:element name="foo-bar" minOccurs="0" maxOccurs="1">
          <xs:complexType>
            <xs:simpleContent>
              <xs:restriction base="String">
              </xs:restriction>
            </xs:simpleContent>
          </xs:complexType>
        </xs:element>
          XML
        end

        sanitize_xml(SomeModel.to_xsd).should eq(xsd)
      end
    end

    context "given a method with validations" do
      with_model :some_model do
        table {}

        model do
          validates :foo_bar, :inclusion => { :in => [1,2,3] }

          def foo_bar=(value)
            @foo_bar = value
          end

          def foo_bar
            @foo_bar
          end

          def to_xml(options = {})
            super({:methods => [:foo_bar]}.merge(options))
          end

          def self.xsd_methods
            {:foo_bar => nil}
          end
        end
      end


      it "should generate validation restrictions for the method if there are any" do
        xsd = generate_xsd_for_model(SomeModel) do
          <<-XML
        <xs:element name="id" minOccurs="0" maxOccurs="1">
          <xs:complexType>
            <xs:simpleContent>
              <xs:restriction base="Integer">
              </xs:restriction>
            </xs:simpleContent>
          </xs:complexType>
        </xs:element>
        <xs:element name="foo-bar" minOccurs="0" maxOccurs="1">
          <xs:complexType>
            <xs:simpleContent>
              <xs:restriction base="String">
                <xs:enumeration value="1"/>
                <xs:enumeration value="2"/>
                <xs:enumeration value="3"/>
              </xs:restriction>
            </xs:simpleContent>
          </xs:complexType>
        </xs:element>
          XML
        end

        sanitize_xml(SomeModel.to_xsd).should eq(xsd)
      end

      it "should validate against the xsd" do
        xsd = SomeModel.to_xsd

        invalid_instance = SomeModel.new(:foo_bar => "d")
        xml = [invalid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, xsd)
        }.should raise_error
        valid_instance = SomeModel.new(:foo_bar => 1)
        xml = [valid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, xsd)
        }.should_not raise_error
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
                  <xs:restriction base="Integer">
                  </xs:restriction>
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
              <xs:restriction base="Integer">
              </xs:restriction>
            </xs:simpleContent>
          </xs:complexType>
        </xs:element>
        <xs:element name="foo" minOccurs="0" maxOccurs="1">
          <xs:complexType>
            <xs:all>
              <xs:element name="bar" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:all>
                    <xs:element name="baz" minOccurs="0" maxOccurs="1">
                      <xs:complexType>
                        <xs:simpleContent>
                          <xs:restriction base="String">
                          </xs:restriction>
                        </xs:simpleContent>
                      </xs:complexType>
                    </xs:element>
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

