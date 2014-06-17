require "spec_helper"

describe Schematic::Generator::Restrictions::Numericality do
  describe ".to_xsd" do
    context "with a model with numericality validations" do
      subject { sanitize_xml(TestModel.to_xsd) }
      with_model :test_model do
        table :id => false do |t|
          t.string "some_field"
        end

        model do
          self.primary_key = :some_field
          validates :some_field, :numericality => true
        end
      end

      it "should validate against it's own XSD" do
        invalid_instance = TestModel.new(:some_field => "1a2")
        xml = [invalid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should raise_error
        valid_instance = TestModel.new(:some_field => "123")
        xml = [valid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should_not raise_error
      end

      it "should mark that the field with the allowed values" do
        xsd = generate_xsd_for_model(TestModel) do
          <<-XML
              <xs:element name="some-field" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="String">
                      <xs:pattern value="\\d+"/>
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

