require "spec_helper"
require "support/extensions/active_model/validations/inclusion"

describe Schematic::Generator::Restrictions::Enumeration do
  describe ".to_xsd" do
    context "with a model with inclusion validations" do
      subject { sanitize_xml(EnumerationModel.to_xsd) }
      with_model :enumeration_model do
        table :id => false do |t|
          t.string "title"
          t.string "should_be_skipped"
          t.string "should_also_be_skipped"
          t.boolean "active"
          t.string "options"
          t.integer "force_enumeration"
        end

        model do
          validates :title, :inclusion => { :in => ["a", "b", "c"] }
          validates :should_be_skipped, :inclusion => ["a", "b", "c"], :if => lambda { false }
          validates :should_also_be_skipped, :inclusion => ["a", "b", "c"], :unless => lambda { false }
          validates :active, :inclusion => { :in => [true, false] }
          validates :options, :inclusion => { :in => lambda { |f| ["some valid attribute"] } }
          validates :force_enumeration, :inclusion => { :in => [1, 2], :xsd => { :include => true} }, :if => lambda { false }
        end
      end

      it "should validate against it's own XSD" do
        invalid_instance = EnumerationModel.new(:title => "d")
        xml = [invalid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should raise_error
        valid_instance = EnumerationModel.new(:title => "a", :should_be_skipped => "a", :should_also_be_skipped => "a", :active => true, :options => "some valid attribute", :force_enumeration => 2)
        xml = [valid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should_not raise_error
      end

      it "should mark that the field with the allowed values" do
        xsd = generate_xsd_for_model(EnumerationModel) do
          <<-XML
              <xs:element name="title" minOccurs="0" maxOccurs="1">
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
              <xs:element name="should-be-skipped" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="String">
                    </xs:restriction>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
              <xs:element name="should-also-be-skipped" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="String">
                    </xs:restriction>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
              <xs:element name="active" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="Boolean">
                    </xs:restriction>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
              <xs:element name="options" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="String">
                    </xs:restriction>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
              <xs:element name="force-enumeration" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="Integer">
                      <xs:enumeration value="1"/>
                      <xs:enumeration value="2"/>
                    </xs:restriction>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
          XML
        end

        subject.should == xsd
      end
    end
  end
end


