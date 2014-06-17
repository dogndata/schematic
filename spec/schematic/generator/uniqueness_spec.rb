require "spec_helper"

describe Schematic::Generator::Uniqueness do
  describe ".to_xsd" do
    context "with a model with a uniqueness validation" do
      subject { sanitize_xml(TestModel.to_xsd) }
      with_model :test_model do
        table :id => false do |t|
          t.string "some_field"
        end

        model do
          self.primary_key = :some_field
          validates :some_field, :uniqueness => true
        end
      end

      it "should validate against it's own XSD" do
        first_instance = TestModel.new(:some_field => "first")
        another_instance = TestModel.new(:some_field => "second")
        duplicate_instance = TestModel.new(:some_field => "first")
        xml = [first_instance, duplicate_instance, another_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should raise_error
        xml = [first_instance, another_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should_not raise_error
      end

      it "should mark that the field with the allowed values" do
        header_element = <<-XML
          <xs:unique name="some-field-must-be-unique">
            <xs:selector xpath="./test-model"/>
            <xs:field xpath="some-field"/>
          </xs:unique>
        XML
        xsd = generate_xsd_for_model(TestModel, header_element) do
          <<-XML
            <xs:element name="some-field" minOccurs="0" maxOccurs="1">
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

    context "for a model with a column with uniqueness with scope" do
      subject { sanitize_xml(TestModel.to_xsd) }

      shared_examples_for "single field in scope" do
        it "should validate against it's own XSD" do
          first_instance = TestModel.new(:some_field => "first", :other_field => "unique")
          another_instance = TestModel.new(:some_field => "first", :other_field => "alsounique")
          duplicate_instance = TestModel.new(:some_field => "first", :other_field => "unique")
          xml = [first_instance, duplicate_instance, another_instance].to_xml
          lambda {
            validate_xml_against_xsd(xml, subject)
          }.should raise_error
          xml = [first_instance, another_instance].to_xml
          lambda {
            validate_xml_against_xsd(xml, subject)
          }.should_not raise_error
        end
      end

      context "when the scope is a symbol" do
        with_model :test_model do
          table :id => false do |t|
            t.string "some_field"
            t.string "other_field"
          end

          model do
            self.primary_key = :some_field
            validates :some_field, :uniqueness => { :scope => :other_field }
          end
        end

        it_behaves_like "single field in scope"
      end

      context "when the scope is an array" do
        with_model :test_model do
          table :id => false do |t|
            t.string "some_field"
            t.string "other_field"
          end

          model do
            self.primary_key = :some_field
            validates :some_field, :uniqueness => { :scope => [:other_field] }
          end
        end

        it_behaves_like "single field in scope"
      end
    end

    context "for a model with mutiple columns seperately having uniqueness" do
      subject { sanitize_xml(TestModel.to_xsd) }
      with_model :test_model do
        table :id => false do |t|
          t.string "some_field"
          t.string "other_field"
        end

        model do
          self.primary_key = :some_field
          validates :some_field, :uniqueness => true
          validates :other_field, :uniqueness => true
        end
      end

      it "should validate against it's own XSD" do
        first_instance = TestModel.new(:some_field => "first", :other_field => "unique")
        another_instance = TestModel.new(:some_field => "another", :other_field => "alsounique")
        duplicate_instance = TestModel.new(:some_field => "first", :other_field => "duplicate")
        other_duplicate_instance = TestModel.new(:some_field => "fourth", :other_field => "unique")

        xml = [first_instance, duplicate_instance, another_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should raise_error

        xml = [first_instance, other_duplicate_instance, another_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should raise_error

        xml = [first_instance, another_instance].to_xml
        lambda {
          validate_xml_against_xsd(xml, subject)
        }.should_not raise_error
      end
    end

  end
end


