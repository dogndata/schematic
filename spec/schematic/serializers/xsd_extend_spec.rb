require 'spec_helper'

describe Schematic::Serializers::Xsd do
  with_model :empty_model

  before do
    class EmptyClass
      include ActiveModel::Serializers::Xml
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

    context "when the class has ActiveModel::Serializers::Xml as an ancestor" do
      subject { EmptyClass }

      it "should raise an exception" do
        lambda {
          subject.class_eval do
            extend Schematic::Serializers::Xsd
          end
        }.should raise_error(Schematic::ClassMissingAttributes)
      end

      context "and it implements #attributes" do
        before do
          class EmptyClass
            def attributes
              {}
            end
          end
        end
        it "should allow the model to be extended" do
          lambda {
            subject.class_eval do
              extend Schematic::Serializers::Xsd
            end
          }.should_not raise_error
        end
      end
    end

    context "when the class does not have ActiveModel::Serializers::Xml as an ancestor" do
      subject { Object }

      it "should raise an exception" do
        lambda {
          subject.class_eval do
          extend Schematic::Serializers::Xsd
          end
        }.should raise_error(Schematic::ClassMissingXmlSerializer)
      end
    end
  end
end
