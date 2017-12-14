require 'spec_helper'

describe "Schematic::Generator::Restrictions::Mixin" do
  describe ".to_xsd" do
    context "with a model with a mixed in restriction" do
      before do
        class MixedInRestriction < Schematic::Generator::Restrictions::Base
          def generate(builder)
            for_validator ActiveModel::BlockValidator do |validator|
              builder.xs(:enumeration, 'value' => 'cheese')
            end
          end
        end
      end

      subject { sanitize_xml(TestModel.to_xsd) }
      with_model :test_model do
        table :id => false do |t|
          t.string 'title'
        end

        model do
          self.primary_key = :title
          validates_each :title do |object, attr, value|
          end
        end
      end

      it "should validate against it's own XSD" do
        invalid_instance = TestModel.new(:title => 'cake')
        xml = [invalid_instance].to_xml
        expect {
          validate_xml_against_xsd(xml, subject)
        }.to raise_error RSpec::Expectations::ExpectationNotMetError
        valid_instance = TestModel.new(:title => 'cheese')
        xml = [valid_instance].to_xml
        expect {
          validate_xml_against_xsd(xml, subject)
        }.not_to raise_error
      end

      it "should mark that the field with the allowed values" do
        xsd = generate_xsd_for_model(TestModel) do
          <<-XML
              <xs:element name="title" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="String">
                      <xs:enumeration value="cheese"/>
                    </xs:restriction>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
          XML
        end

        expect(subject).to eq(xsd)
      end
    end
  end
end
