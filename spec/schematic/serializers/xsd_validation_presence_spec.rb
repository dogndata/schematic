require "spec_helper"

describe Schematic::Serializers::Xsd do
  describe ".to_xsd" do
    context "with a model with presence of validations" do
      subject { sanitize_xml(SomeModel.to_xsd) }
      context "when allow blank is true" do
        with_model :some_model do
          table :id => false do |t|
            t.string "title"
          end

          model do
            validate :title, :presence => true, :allow_blank => true
          end
        end

        it "should mark that the field minimum occurrences is 0" do
          xsd = generate_xsd_for_model(SomeModel) do
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

      context "when allow blank is false" do
        with_model :some_model do
          table :id => false do |t|
            t.string "title"
          end

          model do
            validates :title, :presence => true
          end
        end

        it "should mark that the field minimum occurrences is 1" do
          xsd = generate_xsd_for_model(SomeModel) do
            <<-XML
              <xs:element name="title" minOccurs="1" maxOccurs="1" nillable="false">
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

      context "when there is a condition" do
        with_model :some_model do
          table :id => false do |t|
            t.string "title"
            t.string "description"
          end

          model do
            validates :title, :presence => true, :if => lambda { |model| false }
            validates :description, :presence => true, :unless => lambda { |model| true }
          end
        end

        it "should mark that the field minimum occurrences is 0" do
          xsd = generate_xsd_for_model(SomeModel) do
            <<-XML
              <xs:element name="title" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="String">
                    </xs:restriction>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
              <xs:element name="description" minOccurs="0" maxOccurs="1">
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

    context "with a model with field explicitly required" do
      subject { sanitize_xml(SomeModel.to_xsd) }
      context "when allow blank is true" do
        with_model :some_model do
          table :id => false do |t|
            t.boolean "current"
          end

          model do
            schematic do
              required :current
            end
          end
        end

        it "should mark that the field minimum occurrences is 1" do
          xsd = generate_xsd_for_model(SomeModel) do
            <<-XML
              <xs:element name="current" minOccurs="1" maxOccurs="1" nillable="false">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="Boolean">
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
