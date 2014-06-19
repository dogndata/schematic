require 'spec_helper'

describe Schematic::Serializers::Xsd do
  describe "schematic#ignore keyword" do
    with_model :some_model do
      table :id => false do |t|
        t.string :title
      end

      model do
        self.primary_key = :title
        schematic do
          ignore :title
        end
      end
    end

    it "should exclude the methods" do
      xsd = generate_xsd_for_model(SomeModel) do
      end

      expect(sanitize_xml(SomeModel.to_xsd)).to eq(xsd)
    end
  end
end
