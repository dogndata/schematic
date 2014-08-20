require 'spec_helper'

describe Schematic::Serializers::Xsd do
  before do
    class EmptyModel < ActiveRecord::Base

      def self.columns
        []
      end
    end
  end

  describe ".to_xsd" do

    context "XSD validation" do
      context "for a normal class that has XML serialization" do
        subject { SomeClass.to_xsd }

        before do
          class SomeClass
            include ActiveModel::Serializers::Xml
            attr_accessor :foo, :bar
            def attributes=(hash)
              @hash = hash
            end

            def attributes
              @hash
            end
            extend Schematic::Serializers::Xsd
            schematic do
              add :foo
            end
          end
        end

        it "should generate a valid XSD" do
          validate_xsd(subject)
        end

        it "should validate against its own XSD" do
          invalid_instance = SomeClass.new
          invalid_instance.attributes = { 'bar' => 'foo' }
          xml = [invalid_instance].to_xml
          expect {
            validate_xml_against_xsd(xml, subject)
          }.to raise_error

          instance = SomeClass.new
          instance.attributes = { 'foo' => 'bar' }
          xml = [instance].to_xml
          validate_xml_against_xsd(xml, subject)
        end
      end

      context "when the model is not namespaced" do
        subject { SomeModel.to_xsd }

        with_model :some_model do
          table :id => false do |t|
            t.string 'some_string'
            t.text 'some_text'
            t.float 'some_float'
            t.integer 'some_integer'
            t.datetime 'some_datetime'
            t.date 'some_date'
            t.boolean 'some_boolean'
            t.text "method_is_also_columns"
          end

          model do
            self.primary_key = :some_string

            validates :some_string, :presence => true, :length => { :maximum => 100 }
            validates :some_text, :presence => true
            validates :some_date, :presence => true, :allow_blank => true
            validates :some_datetime, :presence => true, :allow_blank => false
            attr_accessor :additional_method_array
            schematic do
              add :foo => { :bar => { :baz => nil }, :quz => [:qaz] }
              add :method_is_also_columns => [:method_is_also_column]
              add :additional_method_array => []
            end

            def to_xml(options)
              super({:methods => [:additional_method_array]}.merge(options))
            end
          end

        end

        it "should generate a valid XSD" do
          validate_xsd(subject)
        end

        it "should validate against it's own XSD" do
          instance = SomeModel.new(:some_string => 'ExampleString',
                                   :some_date => Date.today,
                                   :some_text => 'here is some text',
                                   :some_datetime => DateTime.new,
                                   :some_boolean => true,
                                   :some_float => 1.5,
                                   :method_is_also_columns => ['somevalues'],
                                   :additional_method_array => {'somevalue' => 'somekey'},
                                   :some_integer => 2)
          xml = [instance].to_xml
          validate_xml_against_xsd(xml, subject)
        end
      end

      context "when the model is namespaced" do
        before do
          module Namespace; end
        end

        subject { Namespace::SomeModel.to_xsd }

        with_model :some_model do
          table do |t|
            t.string 'some_string'
          end

          model do
            validates :some_string, :presence => true
          end

        end

        before do
          class Namespace::SomeModel < SomeModel
          end
        end

        it "should generate a valid XSD" do
          validate_xsd(subject)
        end
      end

      context "when the model has a nested attribute on a subclass with a reference to the superclass" do
        with_model :child do
          table do |t|
            t.integer :parent_id
          end
        end
        with_model :parent do
        end

        before do
          ::Child.class_eval do
            belongs_to :parent
          end
          module Namespace
            if defined?(SubChild)
             remove_const(:SubChild)
            end
          end
          class Namespace::SubChild < ::Child
            accepts_nested_attributes_for :parent
          end
          ::Parent.class_eval do
            has_many :children, :class_name => 'Namespace::SubChild'
            accepts_nested_attributes_for :children
          end
        end

        subject { Namespace::SubChild.to_xsd }

        it "should generate a valid xsd and validate against its own XSD" do
          validate_xsd(subject)
          child_instance = Namespace::SubChild.new(:parent_id => 123)
          child_instance.save!
          xml = [child_instance].to_xml
          expect {
            validate_xml_against_xsd(xml, subject)
          }.not_to raise_error
        end
      end

      context "when the model has a nested attribute on a subclass with a different class name than the has_many association" do
        with_model :parent2 do
          model do
            has_many :children, :class_name => 'SpecialChild'
            accepts_nested_attributes_for :children
          end
        end

        with_model :special_child do
          table do |t|
            t.integer :parent_id
          end

          model do
            belongs_to :parent2
          end
        end

        subject { Parent2.to_xsd }

        it "should generate a valid XSD" do
          expect(subject).to include 'children-attributes'
          expect(subject).not_to include 'special-children-attributes'
          validate_xsd(subject)
        end
      end

      context "when the model has a nested attribute for a has_one association" do
        with_model :car do
          model do
            has_one :engine
            accepts_nested_attributes_for :engine
          end
        end

        with_model :engine do
          table do |t|
            t.integer :car_id
          end

          model do
            belongs_to :car
          end
        end

        subject { Car.to_xsd }

        it "should generate a valid XSD" do
          expect(subject).to include 'engine-attributes'
          expect(subject).not_to include 'engines-attributes'
          expect(subject).not_to include 'Engines'
          validate_xsd(subject)
        end
      end

      context "when the model has a nested attribute which is ignored" do
        with_model :car do
          model do
            has_one :engine
            accepts_nested_attributes_for :engine
            schematic do
              ignore :engine
            end
          end
        end

        with_model :engine do
          table do |t|
            t.integer :car_id
          end

          model do
            belongs_to :car
          end
        end

        subject { Car.to_xsd }

        it "should generate a valid XSD" do
          expect(subject).not_to include 'engine-attributes'
          validate_xsd(subject)
        end
      end

      context "when the model has a nested attribute and ignores one of the methods of the nested attribute" do
        with_model :parent do
          model do
            has_one :child
            accepts_nested_attributes_for :child
            schematic do
              ignore :child => [:last_name]
            end
          end
        end

        with_model :child do
          table do |t|
            t.integer :parent_id
            t.string :first_name
            t.string :last_name
          end

          model do
            belongs_to :parent
          end
        end

        describe "the parent XSD" do
          subject { Parent.to_xsd }

          it "should be valid" do
            expect(subject).to include 'child-attributes'
            expect(subject).to include 'first-name'
            expect(subject).not_to include 'last-name'
            validate_xsd(subject)
          end
        end

        describe "the child XSD" do
          subject { Child.to_xsd }

          it "should be valid" do
            expect(subject).to include 'first-name'
            expect(subject).to include 'last-name'
            validate_xsd(subject)
          end
        end
      end

      context "when the model has a nested attribute and ignores one of the methods of the nested attribute" do
        with_model :parent do
          table do |t|
            t.string :first_name
            t.string :last_name
          end

          model do
            has_one :child
            accepts_nested_attributes_for :child
            schematic do
              ignore :child => [:last_name]
            end
          end
        end

        with_model :child do
          table do |t|
            t.integer :parent_id
            t.string :first_name
            t.string :last_name
          end

          model do
            belongs_to :parent
          end
        end

        describe "the parent XSD" do
          subject { Parent.to_xsd }

          it "should be valid" do
            expect(subject).to include 'child-attributes'
            expect(subject).to include 'first-name'
            expect(subject).to include 'last-name'
            validate_xsd(subject)
          end
        end

        describe "the child XSD" do
          subject { Child.to_xsd }

          it "should be valid" do
            expect(subject).to include 'first-name'
            expect(subject).to include 'last-name'
            validate_xsd(subject)
          end
        end
      end

      context "when the model has a nested attribute and ignores a required method of the nested attribute" do
        with_model :person do
          model do
            has_one :house
            accepts_nested_attributes_for :house
            schematic do
              ignore :house => [:address]
            end
          end
        end

        with_model :house do
          table do |t|
            t.string :address
            t.integer :price
            t.belongs_to :person
          end
          model do
            belongs_to :person
            validates :address, presence: true
          end
        end

        describe "the parent XSD" do
          subject { Person.to_xsd }
          it "should be valid" do
            expect(subject).to include %q{"house-attributes"}
            expect(subject).to include %q{"price"}
            expect(subject).not_to include %q{"address"}
            validate_xsd(subject)
          end
        end

        describe "the child XSD" do
          subject { House.to_xsd }
          it "should be valid" do
            expect(subject).to include %q{"price"}
            expect(subject).to include %q{"address"}
            validate_xsd(subject)
          end
        end
      end

      context "when the model has a belongs_to nested attribute with an alternate class name" do
        with_model :school do
          table do |t|
            t.string :name
          end
        end

        with_model :student do
          table do |t|
            t.string :university_id
          end

          model do
            belongs_to :university, class_name: 'School'

            accepts_nested_attributes_for :university
          end
        end

        describe "the parent XSD" do
          subject { School.to_xsd }
          it "should be valid" do
            validate_xsd(subject)
          end
        end

        describe "the child XSD" do
          subject { Student.to_xsd }
          it "should be valid" do
            validate_xsd(subject)
          end

          it "should validate XML" do
            xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<students type="array">
  <student>
    <university-attributes>
      <name>Harvard</name>
    </university>
  </student>
</students>
            XML
            validate_xml_against_xsd(xml, subject)
          end
        end
      end

      context "when the model has a polymorphic nested attribute and ignores a required method of the nested attribute" do
        with_model :person do
          model do
            has_one :house, as: :homeowner
            accepts_nested_attributes_for :house
            schematic do
              ignore :house => [:address]
            end
          end
        end

        with_model :house do
          table do |t|
            t.string :address
            t.integer :price
            t.belongs_to :homeowner, polymorphic: true
          end
          model do
            belongs_to :homeowner, polymorphic: true
            validates :address, presence: true
          end
        end

        describe "the parent XSD" do
          subject { Person.to_xsd }
          it "should be valid" do
            expect(subject).to include %q{"house-attributes"}
            expect(subject).to include %q{"price"}
            expect(subject).not_to include %q{"address"}
            validate_xsd(subject)
          end
        end

        describe "the child XSD" do
          subject { House.to_xsd }
          it "should be valid" do
            expect(subject).to include %q{"price"}
            expect(subject).to include %q{"address"}
            validate_xsd(subject)
          end
        end
      end

      context "when the model has a circular nested attribute reference" do
        with_model :plate do
          model do
            has_many :cheeses
            accepts_nested_attributes_for :cheeses
          end
        end

        with_model :cheese do
          table do |t|
            t.integer :plate_id
          end

          model do
            belongs_to :plate
            accepts_nested_attributes_for :plate
          end
        end

        subject { Cheese.to_xsd }

        it "should generate a valid XSD" do
          validate_xsd(subject)
        end

      end

      context "when the model has a nested reference that references another nested reference" do
        with_model :blog do
          model do
            has_many :posts
            has_many :readers
            accepts_nested_attributes_for :posts
            accepts_nested_attributes_for :readers
          end
        end

        with_model :post do
          table do |t|
            t.integer :blog_id
          end

          model do
            belongs_to :blog
            has_many :readers
            accepts_nested_attributes_for :blog
            accepts_nested_attributes_for :readers
          end
        end

        with_model :reader do
          table do |t|
            t.integer :blog_id
            t.integer :post_id
          end
        end

        subject { Post.to_xsd }

        it "should generate a valid XSD" do
          validate_xsd(subject)
        end

      end
    end

    context "for an empty model with no attributes or validations" do
      subject { sanitize_xml(EmptyModel.to_xsd) }

      it "should return an xsd for an array of the model" do
        xsd = <<-XML
          <?xml version="1.0" encoding="UTF-8"?>
          <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
            <xs:complexType name="Integer">
            <xs:simpleContent>
            <xs:extension base="xs:integer">
            <xs:attribute name="type" type="xs:string" use="optional"/>
            <xs:attribute name="nil" type="xs:boolean" use="optional"/>
            </xs:extension>
            </xs:simpleContent>
            </xs:complexType>
            <xs:complexType name="Float">
            <xs:simpleContent>
            <xs:extension base="xs:float">
            <xs:attribute name="type" type="xs:string" use="optional"/>
            <xs:attribute name="nil" type="xs:boolean" use="optional"/>
            </xs:extension>
            </xs:simpleContent>
            </xs:complexType>
            <xs:complexType name="String">
            <xs:simpleContent>
            <xs:extension base="xs:string">
            <xs:attribute name="type" type="xs:string" use="optional"/>
            <xs:attribute name="nil" type="xs:boolean" use="optional"/>
            </xs:extension>
            </xs:simpleContent>
            </xs:complexType>
            <xs:complexType name="Text">
            <xs:simpleContent>
            <xs:extension base="xs:string">
            <xs:attribute name="type" type="xs:string" use="optional"/>
            <xs:attribute name="nil" type="xs:boolean" use="optional"/>
            </xs:extension>
            </xs:simpleContent>
            </xs:complexType>
            <xs:complexType name="DateTime">
            <xs:simpleContent>
            <xs:extension base="xs:dateTime">
            <xs:attribute name="type" type="xs:string" use="optional"/>
            <xs:attribute name="nil" type="xs:boolean" use="optional"/>
            </xs:extension>
            </xs:simpleContent>
            </xs:complexType>
            <xs:complexType name="Date">
            <xs:simpleContent>
            <xs:extension base="xs:date">
            <xs:attribute name="type" type="xs:string" use="optional"/>
            <xs:attribute name="nil" type="xs:boolean" use="optional"/>
            </xs:extension>
            </xs:simpleContent>
            </xs:complexType>
            <xs:complexType name="Boolean">
            <xs:simpleContent>
            <xs:extension base="xs:boolean">
            <xs:attribute name="type" type="xs:string" use="optional"/>
            <xs:attribute name="nil" type="xs:boolean" use="optional"/>
            </xs:extension>
            </xs:simpleContent>
            </xs:complexType>
            <xs:element name="empty-models" type="EmptyModels">
            </xs:element>
            <xs:complexType name="EmptyModels">
              <xs:sequence>
                <xs:element name="empty-model" type="EmptyModel" minOccurs="0" maxOccurs="unbounded"/>
              </xs:sequence>
              <xs:attribute name="type" type="xs:string" fixed="array"/>
            </xs:complexType>
            <xs:complexType name="EmptyModel">
              <xs:all>
              </xs:all>
            </xs:complexType>
          </xs:schema>
        XML
        expect(subject).to eq(sanitize_xml(xsd))
      end

    end

    context "for a model with attributes" do

      subject { sanitize_xml(SomeModel.to_xsd) }

      context "for a any attribute" do
        with_model :some_model do
          table :id => false do |t|
            t.float 'some_float'
          end

          model do
            self.primary_key = :some_float
          end
        end

        it "should define the correct xsd element" do
          xsd = generate_xsd_for_model(SomeModel) do
            <<-XML
              <xs:element name="some-float" minOccurs="0" maxOccurs="1">
                <xs:complexType>
                  <xs:simpleContent>
                    <xs:restriction base="Float">
                    </xs:restriction>
                  </xs:simpleContent>
                </xs:complexType>
              </xs:element>
            XML
          end

          expect(subject).to eq(xsd)
        end

      end

      describe "additional methods" do
        with_model :some_model do
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

          expect(sanitize_xml(SomeModel.to_xsd(:methods => {:foo_bar => nil}))).to eq(xsd)
        end
      end

    end

    context "a model that specifies a different root element" do
      with_model :ModelWithDifferentRoot do
        model do
          schematic do
            root 'my_root'
          end
        end
      end

      subject { ModelWithDifferentRoot.to_xsd }

      it "should use the new root tag name" do
        expect(subject).not_to include %q{"model-with-different-root"}
        expect(subject).not_to include %q{"model-with-different-roots"}
        expect(subject).to include %q{"my-root"}
        expect(subject).to include %q{"my-roots"}
        validate_xsd(subject)
      end
    end

  end

  describe "#nested_attribute_name" do
    let(:xsd) {Schematic::Generator::Xsd.new(Object)}
    it "turns 'child' into 'children-attributes'" do
      expect(xsd.nested_attribute_name('child')).to eq('children-attributes')
    end

    it "turns 'children' into 'children-attributes'" do
      expect(xsd.nested_attribute_name('children')).to eq('children-attributes')
    end

    it "turns 'special-children' into 'special-children-attributes'" do
      expect(xsd.nested_attribute_name('special_children')).to eq('special-children-attributes')
    end

    it "properly converts symbols" do
      expect(xsd.nested_attribute_name(:very_special_children)).to eq('very-special-children-attributes')
    end
  end
  context "when the model has a nested attribute with a different class name and foreign key than the has_many association" do
    with_model :foo do
      model do
        has_one :bar, :class_name => 'Quz', :foreign_key => 'bar_id'
        has_many :children, :class_name => 'Quz', :foreign_key => 'children_id'
        accepts_nested_attributes_for :children
        accepts_nested_attributes_for :bar
      end
    end
    with_model :quz do
      table do |t|
        t.integer :bar_id
        t.integer :children_id
        t.string :name
      end
    end
    subject { Foo.to_xsd }

    it "should generate a valid XSD" do
      test_xml = <<-END
      <?xml version="1.0" encoding="UTF-8"?>
      <foos>
        <foo>
          <children-attributes>
            <quz>
              <name>Joe</name>
            </quz>
          </children-attributes>
        </foo>
      </foos>
      END

      expect(subject).to include 'Quz'
      expect(subject).to include 'Quzs'
      validate_xml_against_xsd(test_xml, subject)
    end
  end
end
