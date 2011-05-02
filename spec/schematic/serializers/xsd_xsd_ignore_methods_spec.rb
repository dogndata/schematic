require "spec_helper"

describe Schematic::Serializers::Xsd do
  describe ".xsd_ignore_methods" do
    with_model :some_model do
      table :id => false do |t|
        t.string :title
      end

      model do
        def self.xsd_ignore_methods
          [:title]
        end
      end
    end

    it "should exclude the methods" do
      xsd = generate_xsd_for_model(SomeModel) do
      end

      sanitize_xml(SomeModel.to_xsd).should eq(xsd)
    end
  end

end
