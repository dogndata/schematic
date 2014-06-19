require 'spec_helper'

describe Schematic::Generator::Restrictions::Length do
  describe ".to_xsd" do
    context "with a model with range length validations" do
      subject { sanitize_xml(LengthModelRange.to_xsd) }
      with_model :length_model_range do
        table :id => false do |t|
          t.string 'title'
        end

        model do
          self.primary_key = :title
          validates :title, :length => { :within => 10..20 }
        end
      end

      it "should validate against it's own XSD" do
        invalid_instance = LengthModelRange.new(:title => 'A' * 9)
        xml = [invalid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should raise_error
        invalid_instance = LengthModelRange.new(:title => 'A' * 21)
        xml = [invalid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should raise_error
      end
    end

    context "with a model with using the range alias length validations" do
      subject { sanitize_xml(LengthModelRange.to_xsd) }
      with_model :length_model_range do
        table :id => false do |t|
          t.string "title"
        end

        model do
          self.primary_key = :title
          validates :title, :length => { :in => 10..20 }
        end
      end

      it "should validate against it's own XSD" do
        invalid_instance = LengthModelRange.new(:title => 'A' * 9)
        xml = [invalid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should raise_error
        invalid_instance = LengthModelRange.new(:title => 'A' * 21)
        xml = [invalid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should raise_error
      end
    end

    context "with a model with minimum length validations" do
      subject { sanitize_xml(LengthModelMinimum.to_xsd) }
      with_model :length_model_minimum do
        table :id => false do |t|
          t.string 'title'
        end

        model do
          self.primary_key = :title
          validates :title, :length => { :minimum => 10 }
        end
      end

      it "should validate against it's own XSD" do
        invalid_instance = LengthModelMinimum.new(:title => 'A' * 9)
        xml = [invalid_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should raise_error
      end
    end

    context "with a model with maximum length validations" do
      subject { sanitize_xml(LengthModelOne.to_xsd) }
      context "when allow blank is true" do
        with_model :length_model_one do
          table :id => false do |t|
            t.string 'title'
          end

          model do
            self.primary_key = :title
            validates :title, :length => { :maximum => 100 }, :allow_blank => true
          end
        end

        it "should validate against it's own XSD" do
          invalid_instance = LengthModelOne.new(:title => 'A' * 201)
          xml = [invalid_instance].to_xml
          lambda {
            validate_xml_against_xsd(xml, subject)
          }.should raise_error
        end

        it "should mark that the field minimum occurrences is 0 but still list the length" do
          xsd = generate_xsd_for_model(LengthModelOne) do
            <<-XML
              <xs:element name="title" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="String">
                      <xs:maxLength value="100"/>
                    </xs:restriction>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
            XML
          end

          subject.should == xsd
        end
      end

      context "when allow blank is false" do
        subject { sanitize_xml(LengthModelTwo.to_xsd) }
        with_model :length_model_two do
          table :id => false do |t|
            t.string 'title'
          end

          model do
            self.primary_key = :title
            validates :title, :length => { :maximum => 100 }
          end
        end

        it "should mark that the field maximum length to 100" do
          xsd = generate_xsd_for_model(LengthModelTwo) do
            <<-XML
              <xs:element name="title" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="String">
                      <xs:maxLength value="100"/>
                    </xs:restriction>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
            XML
          end

          subject.should == xsd
        end
      end

      context "when there is a condition" do
        subject { sanitize_xml(LengthModelThree.to_xsd) }
        with_model :length_model_three do
          table :id => false do |t|
            t.string 'title'
          end

          model do
            self.primary_key = :title
            validates :title, :length => { :maximum => 100 }, :if => lambda { |model| false }
          end
        end

        it "should not record the max length" do
          xsd = generate_xsd_for_model(LengthModelThree) do
            <<-XML
              <xs:element name="title" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="String">
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
end
