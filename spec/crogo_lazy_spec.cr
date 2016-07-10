require "./spec_helper"

class LazyTest
  include Crogo::Lazy

  def initialize(data = {} of String => Crogo::Lazy::LAZY_TYPES)
    lazy_init!(data)
  end

  attribute :simple_string, String
  attribute :simple_defaulted, String, default: ->{"omg"}
end

class LazyRequired
  include Crogo::Lazy

  def initialize(data = {} of String => Crogo::Lazy::LAZY_TYPES)
    lazy_init!(data)
  end

  attribute :required_string, String, required: true
  attribute :required_string_defaulted, String, required: true, default: "value"
end


describe Crogo::Lazy do

  it "should have a simple_string attribute" do
    t = LazyTest.new
    t.simple_string = "hi"
    t.simple_string.should eq("hi")
  end

  it "should have a default_string attribute with default value" do
    t = LazyTest.new
    t.simple_defaulted.should eq("omg")
  end

  it "should replace default_string attribute value with new value" do
    t = LazyTest.new
    t.simple_defaulted.should eq("omg")
    t.simple_defaulted = "hi"
    t.simple_defaulted.should eq("hi")
  end

  it "should initialize with given value" do
    t = LazyTest.new({"simple_defaulted" => "hi"})
    t.simple_defaulted.should eq("hi")
  end

  it "should unset value after being set" do
    t = LazyTest.new
    t.simple_string = "hi"
    t.simple_string.should eq("hi")
    t.simple_string = nil
    t.simple_string.should be_nil
  end

  it "should raise exception when no value provided for required" do
    expect_raises(Crogo::Error::RequiredValue) do
      LazyRequired.new
    end
  end

  it "should initialize when required value is provided" do
    t = LazyRequired.new({"required_string" => "req"})
    t.required_string.should eq("req")
  end

  it "should set required value to default when no value provided on init" do
    t = LazyRequired.new({"required_string" => "req"})
    t.required_string_defaulted.should eq("value")
  end

  it "should error when required value is unset" do
    t = LazyRequired.new({"required_string" => "req"})
    expect_raises(Crogo::Error::RequiredValue) do
      t.required_string = nil
    end
  end

  it "should show unaltered instance as clean" do
    t = LazyTest.new
    t.clean?.should be_true
    t.dirty?.should be_false
  end

  it "should show altered instance as dirty" do
    t = LazyTest.new
    t.simple_string = "hi"
    t.clean?.should be_false
    t.dirty?.should be_true
  end

  it "should provide dirty values" do
    t = LazyTest.new
    t.simple_string = "hi"
    t.dirty.empty?.should be_false
    t.dirty[:simple_string].should be_a(Crogo::Attribute(String))
    t.dirty[:simple_string].original.should be_nil
    t.dirty[:simple_string].get.should eq("hi")
  end

  it "should clean dirty values" do
    t = LazyTest.new
    t.simple_string = "hi"
    t.dirty.empty?.should be_false
    t.dirty[:simple_string].should be_a(Crogo::Attribute(String))
    t.dirty[:simple_string].original.should be_nil
    t.dirty[:simple_string].get.should eq("hi")
    t.clean!
    t.dirty?.should be_false
  end

end
