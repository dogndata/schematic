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
        subject.ignored_elements.should include(:foo)
      end

      it "accepts multiple fields" do
        subject.run do
          ignore :foo, :bar
        end
        subject.ignored_elements.should include(:foo)
        subject.ignored_elements.should include(:bar)
      end
    end

    context "on nested elements" do
      it "should remove the method to the element list" do
        subject.run do
          ignore :foo => [:bar]
        end
        subject.ignored_elements[:foo].should == [:bar]
      end
    end
  end

  describe "adding elements" do
    context "given a single element" do
      it "should add the method to the element list" do
        subject.run do
          add :foo
        end
        subject.added_elements.keys.should include(:foo)
      end
    end

    context "nesting elements" do
      it "should add the method to the element list" do
        subject.run do
          add :foo => { :bar => nil }
        end
        subject.added_elements[:foo].should == { :bar => nil }
      end
    end

    context "sequence of subelements" do
      it "should add the method to the element list" do
        subject.run do
          add :foo => [:bar]
        end
        subject.added_elements[:foo].should == [:bar]
      end
    end
  end

  describe "requiring elements" do
    it "should add the method to the required list" do
      subject.run do
        required :foo
      end
      subject.required_elements.should include(:foo)
    end

    it "accepts multiple fields" do
      subject.run do
        required :foo, :bar
      end
      subject.required_elements.should include(:foo)
      subject.required_elements.should include(:bar)
    end
  end

  describe "not requiring elements" do
    it "should add the method to the non-required list" do
      subject.run do
        not_required :foo
      end
      subject.non_required_elements.should include(:foo)
    end

    it "accepts multiple fields" do
      subject.run do
        not_required :foo, :bar
      end
      subject.non_required_elements.should include(:foo)
      subject.non_required_elements.should include(:bar)
    end
  end

  describe "setting the root" do
    it "should change the root element name" do
      subject.run do
        root 'my_new_root'
      end

      subject.xsd_generator.names.element.should == 'my-new-root'
      subject.xsd_generator.names.element_collection.should == 'my-new-roots'
    end
  end
end
