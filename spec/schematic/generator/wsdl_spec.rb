require "spec_helper"

describe Schematic::Generator::Wsdl do
  let(:generator) do
    Schematic::Generator::Wsdl.new(
      :location => "http://mylocation.wsdl",
      :models => SomeModel
    )
  end

  with_model :some_model do
    table :id => false do |t|
      t.string "some_string"
      t.boolean "some_boolean"
    end

    model do
      validates :some_string, :presence => true, :length => { :maximum => 100 }
    end

  end

  describe "#to_wsdl" do
    subject { generator.to_wsdl }

    it "should generate a valid WSDL" do
      validate_wsdl(subject)
    end
  end
end

