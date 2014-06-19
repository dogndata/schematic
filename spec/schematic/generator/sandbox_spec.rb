require 'spec_helper'

describe Schematic::Generator::Sandbox do
  subject { Schematic::Generator::Sandbox.new(klass) }
  let(:klass) { Object }

  describe "ignoring elements" do
    context "on the base element" do
      it "should add the method to the ignored list" do
        subject.run do
          ignore :foo
        end
        expect(subject.ignored_elements).to include(:foo)
      end

      it "accepts multiple fields" do
        subject.run do
          ignore :foo, :bar
        end
        expect(subject.ignored_elements).to include(:foo)
        expect(subject.ignored_elements).to include(:bar)
      end
    end

    context "on nested elements" do
      it "should remove the method to the element list" do
        subject.run do
          ignore :foo => [:bar]
        end
        expect(subject.ignored_elements[:foo]).to eq([:bar])
      end
    end
  end

  describe "adding elements" do
    context "given a single element" do
      it "should add the method to the element list" do
        subject.run do
          add :foo
        end
        expect(subject.added_elements.keys).to include(:foo)
      end
    end

    context "nesting elements" do
      it "should add the method to the element list" do
        subject.run do
          add :foo => { :bar => nil }
        end
        expect(subject.added_elements[:foo]).to eq({ :bar => nil })
      end
    end

    context "sequence of subelements" do
      it "should add the method to the element list" do
        subject.run do
          add :foo => [:bar]
        end
        expect(subject.added_elements[:foo]).to eq([:bar])
      end
    end
  end

  describe "requiring elements" do
    it "should add the method to the required list" do
      subject.run do
        required :foo
      end
      expect(subject.required_elements).to include(:foo)
    end

    it "accepts multiple fields" do
      subject.run do
        required :foo, :bar
      end
      expect(subject.required_elements).to include(:foo)
      expect(subject.required_elements).to include(:bar)
    end
  end

  describe "not requiring elements" do
    it "should add the method to the non-required list" do
      subject.run do
        not_required :foo
      end
      expect(subject.non_required_elements).to include(:foo)
    end

    it "accepts multiple fields" do
      subject.run do
        not_required :foo, :bar
      end
      expect(subject.non_required_elements).to include(:foo)
      expect(subject.non_required_elements).to include(:bar)
    end
  end

  describe "setting the root" do
    it "should change the root element name" do
      subject.run do
        root 'my_new_root'
      end

      expect(subject.xsd_generator.names.element).to eq('my-new-root')
      expect(subject.xsd_generator.names.element_collection).to eq('my-new-roots')
    end
  end
end
