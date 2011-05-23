require "spec_helper"

describe Schematic::Generator::Restrictions::Pattern do
  describe ".to_xsd" do
    context "with a model with format validations" do
      subject { sanitize_xml(PatternModel.to_xsd) }
      with_model :pattern_model do
        table :id => false do |t|
          t.string "title"
        end

        model do
          validates :title, :format => { :with => /[a-z]#[0-9]/ }
        end
      end

      it "should validate against it's own XSD" do
        invalid_instance = PatternModel.new(:title => "1-2")
        xml = [invalid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should raise_error
        valid_instance = PatternModel.new(:title => "a#5")
        xml = [valid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should_not raise_error
      end

      it "should mark that the field with the allowed values" do
        xsd = generate_xsd_for_model(PatternModel) do
          <<-XML
              <xs:element name="title" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="String">
                      <xs:pattern value="[a-z]#[0-9]"/>
                    </xs:restriction>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
          XML
        end

        subject.should == xsd
      end
    end

    context "with a model with a complex format" do
      subject { sanitize_xml(PatternModel.to_xsd) }
      with_model :pattern_model do
        table :id => false do |t|
          t.string "email"
        end

        model do
          validates :email, :format => { :with => /\A([\w\.%\+\-`']+)@([\w\-]+\.)+([\w]{2,})\Z/ }
        end
      end

      it "should validate against it's own XSD" do
        invalid_instance = PatternModel.new(:email => "@blah")
        xml = [invalid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should raise_error
        valid_instance = PatternModel.new(:email => "foo@bar.com")
        xml = [valid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should_not raise_error
      end
    end
  end
end



