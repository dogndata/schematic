require "spec_helper"

describe Schematic::Serializers::Xsd do
  before do
    class EmptyModel < ActiveRecord::Base
      def self.columns
        []
      end
    end
  end

  describe ".extend" do
    context "when the model inherits ActiveRecord::Base" do
      subject { EmptyModel }

      it "should allow the model to be extended" do
        lambda {
          subject.class_eval do
          extend Schematic::Serializers::Xsd
          end
        }.should_not raise_error
      end
    end

    context "when the model does not inherit ActiveRecord::Base" do
      subject { Object }

      it "should raise an exception" do
        lambda {
          subject.class_eval do
          extend Schematic::Serializers::Xsd
          end
        }.should raise_error(Schematic::InvalidClass)
      end
    end
  end
end
