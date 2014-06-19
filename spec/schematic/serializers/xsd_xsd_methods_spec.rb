require 'spec_helper'

describe Schematic::Serializers::Xsd do
  describe "Adding additional methods" do
    context "given a method" do
      with_model :some_model do
        model do
          schematic do
            add :foo_bar
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

        expect(sanitize_xml(SomeModel.to_xsd)).to eq(xsd)
      end
    end

    context "given a method with validations" do
      with_model :some_model do
        table :id => false do |t|
          t.string :foo
        end

        model do
          self.primary_key = :foo
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

          schematic do
            add :foo_bar
          end
        end
      end


      it "should generate validation restrictions for the method if there are any" do
        xsd = generate_xsd_for_model(SomeModel) do
          <<-XML
        <xs:element name="foo" minOccurs="0" maxOccurs="1">
          <xs:complexType>
            <xs:simpleContent>
              <xs:restriction base="String">
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

        expect(sanitize_xml(SomeModel.to_xsd)).to eq(xsd)
      end

      it "should validate against the xsd" do
        xsd = SomeModel.to_xsd

        invalid_instance = SomeModel.new(:foo_bar => "d")
        xml = [invalid_instance].to_xml
        expect {
          validate_xml_against_xsd(xml, xsd)
        }.to raise_error
        valid_instance = SomeModel.new(:foo_bar => 1)
        xml = [valid_instance].to_xml
        expect {
          validate_xml_against_xsd(xml, xsd)
        }.not_to raise_error
      end
    end

    context "given a singular enumeration restriction" do
      with_model :some_model do
        table :id => false do |t|
          t.string :foo
        end

        model do
          self.primary_key = :foo

          attr_accessor :bar

          def self.xsd_bar_enumeration_restrictions
            ["a", "b", "c"]
          end

          schematic do
            add :bar
          end

          def to_xml(options = {})
            super({:methods => [:bar]}.merge(options))
          end
        end
      end

      it "should include the additional methods" do
        xsd = generate_xsd_for_model(SomeModel) do
          <<-XML
            <xs:element name="foo" minOccurs="0" maxOccurs="1">
              <xs:complexType>
                <xs:simpleContent>
                  <xs:restriction base="String">
                  </xs:restriction>
                </xs:simpleContent>
              </xs:complexType>
            </xs:element>
            <xs:element name="bar" minOccurs="0" maxOccurs="1">
              <xs:complexType>
                <xs:simpleContent>
                  <xs:restriction base="String">
                    <xs:enumeration value="a"/>
                    <xs:enumeration value="b"/>
                    <xs:enumeration value="c"/>
                  </xs:restriction>
                </xs:simpleContent>
              </xs:complexType>
            </xs:element>
          XML
        end
        expect(sanitize_xml(SomeModel.to_xsd)).to eq(xsd)
      end

      it "should validate against the xsd" do
        xsd = SomeModel.to_xsd

        invalid_instance = SomeModel.new(:bar => 'invalid option')
        xml = [invalid_instance].to_xml
        expect {
          validate_xml_against_xsd(xml, xsd)
        }.to raise_error
        valid_instance = SomeModel.new(:bar => 'b')
        xml = [valid_instance].to_xml
        expect {
          validate_xml_against_xsd(xml, xsd)
        }.not_to raise_error
      end
    end

    context "given a an array of methods" do
      with_model :some_model do
        table :id => false do |t|
          t.string :bar
        end

        model do
          self.primary_key = :bar

          def foo=(value)
            @foo = value
          end

          def foo
            @foo
          end

          def self.xsd_foo_enumeration_restrictions
            ['1', '2', '3']
          end

          schematic do
            add :foo => [:foo]
          end

          def to_xml(options = {})
            super({:methods => [:foo]}.merge(options))
          end
        end
      end

      it "should include the additional methods" do
        xsd = generate_xsd_for_model(SomeModel) do
          <<-XML
            <xs:element name="bar" minOccurs="0" maxOccurs="1">
              <xs:complexType>
                <xs:simpleContent>
                  <xs:restriction base="String">
                  </xs:restriction>
                </xs:simpleContent>
              </xs:complexType>
            </xs:element>
            <xs:element name="foo" minOccurs="0" maxOccurs="1">
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="foo" minOccurs="0" maxOccurs="unbounded">
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
                </xs:sequence>
                <xs:attribute name="type" type="xs:string" fixed="array" use="optional"/>
              </xs:complexType>
            </xs:element>
          XML
        end
        expect(sanitize_xml(SomeModel.to_xsd)).to eq(xsd)
      end

      it "should validate against its own XSD" do
        invalid_instance = SomeModel.new(:foo => ['a', 'b'])
        xml = [invalid_instance].to_xml
        expect {
          validate_xml_against_xsd(xml, SomeModel.to_xsd)
        }.to raise_error

        instance = SomeModel.new(:foo => ['1', '2'])
        xml = [instance].to_xml
        expect {
          validate_xml_against_xsd(xml, SomeModel.to_xsd)
        }.not_to raise_error
      end
    end

    context "given nested methods" do
      with_model :some_model do
        model do
          schematic do
            add :foo => { :bar => { :baz => nil } }
            add :quz
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
        <xs:element name="quz" minOccurs="0" maxOccurs="1">
          <xs:complexType>
            <xs:simpleContent>
              <xs:restriction base="String">
              </xs:restriction>
            </xs:simpleContent>
          </xs:complexType>
        </xs:element>
          XML
        end

        expect(sanitize_xml(SomeModel.to_xsd)).to eq(xsd)
      end
    end
  end
end
