require "spec_helper"

describe Schematic::Serializers::Xsd do

  describe ".minimum_occurrences_for_column" do
    subject { Schematic::Generator::Column.new(SomeModel, column).minimum_occurrences_for_column }
    let(:column) { SomeModel.columns.first }

    context "given a column with no validations" do
      with_model :some_model do
        table :id => false do |t|
          t.string "title"
        end
        model {}
      end

      it { should == "0" }
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

      it { should == "0" }
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

      it { should == "1" }
    end
  end

end
