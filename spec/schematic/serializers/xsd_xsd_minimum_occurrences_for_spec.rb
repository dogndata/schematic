require "spec_helper"

describe Schematic::Serializers::Xsd do

  describe ".xsd_minimum_occurrences_for" do

    context "given a column with no validations" do
      with_model :some_model do
        table :id => false do |t|
          t.string "title"
        end
        model {}
      end

      it "should return 0" do
        SomeModel.xsd_generator.minimum_occurrences_for_column(SomeModel.columns.first).should == "0"
      end
    end

    context "given a column with presence of but allow blank" do
      with_model :some_model do
        table :id => false do |t|
          t.string "title"
        end
        model do
          validates :title, :presence => true, :allow_blank => true
        end
      end

      it "should return 0" do
        SomeModel.xsd_generator.minimum_occurrences_for_column(SomeModel.columns.first).should == "0"
      end
    end

    context "given a column with presence of and no allow blank" do
      with_model :some_model do
        table :id => false do |t|
          t.string "title"
        end
        model do
          validates :title, :presence => true
        end
      end

      it "should return 1" do
        SomeModel.xsd_generator.minimum_occurrences_for_column(SomeModel.columns.first).should == "1"
      end
    end
  end

end
