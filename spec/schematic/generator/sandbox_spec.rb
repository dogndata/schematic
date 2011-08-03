require "spec_helper"

describe Schematic::Generator::Sandbox do
  subject { Schematic::Generator::Sandbox.new(klass) }
  let(:klass) { Object }

  describe "ignoring elements" do
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

  describe "methods on original object get called when not difined in sandbox module" do
    before do
      klass.stub(:foo)
    end

    it "should delegate missing methods to klass" do
      klass.should_receive(:foo)

      subject.run do
        self.foo
      end
    end
  end
end

