require 'spec_helper'

describe "Schematic::Generator::Restrictions::Custom" do
  describe ".to_xsd" do
    context "with a model with custom validations" do
      before do
        class CrazyTownValidator < ActiveModel::EachValidator
          def validate_each(record, attribute, value)
            record.errors.add(attribute, 'must be crazy') unless value.match /.*crazy.*|\w/
          end

          def xsd_pattern_restrictions
            [/\w/, /.*crazy.*/]
          end
        end
      end

      subject { sanitize_xml(CustomModel.to_xsd) }
      with_model :custom_model do
        table :id => false do |t|
          t.string 'title'
        end

        model do
          self.primary_key = :title
          validates :title, :crazy_town => true
        end
      end

      it "should validate against it's own XSD" do
        invalid_instance = CustomModel.new(:title => 'happy today')
        xml = [invalid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should raise_error
        invalid_instance = CustomModel.new(:title => 'happytoday')
        xml = [invalid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should raise_error
        valid_instance = CustomModel.new(:title => 'iamcrazytoday')
        xml = [valid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should_not raise_error
      end

      it "should mark that the field with the allowed values" do
        xsd = generate_xsd_for_model(CustomModel) do
          <<-XML
              <xs:element name="title" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="String">
                      <xs:pattern value="\\w"/>
                      <xs:pattern value=".*crazy.*"/>
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
