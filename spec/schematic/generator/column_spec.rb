require 'spec_helper'

describe Schematic::Generator::Column do
  describe "#generate" do
    with_model :some_model do
      table :id => false do |t|
        t.integer :id_column
        t.float :float_column
        t.string :string_column
        t.text :text_column
        t.datetime :datetime_column
        t.date :date_column
        t.decimal :decimal_column
      end

      model do
        self.primary_key = :id
      end
    end

    it "should generate xsd" do
      xsd = sanitize_xml(SomeModel.to_xsd)

      Schematic::Generator::Types::COMPLEX.each do |type, value|
        expect(xsd).to include("<xs:complexType name=\"#{value[:complex_type]}\">")
        expect(xsd).to include("<xs:extension base=\"#{value[:xsd_type]}\">")
      end
    end
  end
end
