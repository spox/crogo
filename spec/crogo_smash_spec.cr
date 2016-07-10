require "./spec_helper"

describe Crogo::Smash do

  it "should create a new smash" do
    value = {"key" => "value"} of String => String
    smash = value.to_smash
    smash.should be_a(Crogo::Smash)
  end

  it "should convert complex types to smash" do
    value = {"key" => "value"} of String => Hash(String, String) | String
    value["hash"] = {"hkey" => "hvalue"} of String => String
    smash = value.to_smash
    smash.should be_a(Crogo::Smash)
  end

  it "should fetch deeply nested values from smash" do
    value = {"key" => "value"} of String => Hash(String, String) | String
    value["hash"] = {"hkey" => "hvalue"} of String => String
    smash = value.to_smash
    smash.get(:hash, :hkey, type: :string).should eq("hvalue")
  end

  it "should deep merge two smashes" do
    base = {"key" => "value"} of String => Hash(String, String) | String
    base["nested"] = {"nkey" => "nvalue"} of String => String
    over = {"otherkey" => "othervalue"} of String => Hash(String, String) | String
    over["nested"] = {"xkey" => "xvalue"} of String => String
    b_smash = base.to_smash
    o_smash = over.to_smash
    result = Crogo::Smash.deep_merge(b_smash, o_smash)
    result["key"].should eq("value")
    result["otherkey"].should eq("othervalue")
    result.get(:nested, :nkey, type: :string).should eq("nvalue")
    result.get(:nested, :xkey, type: :string).should eq("xvalue")
  end

  it "should knockout non-hash types on deep merge" do
    base = {"key" => "value"} of String => Hash(String, String) | String
    base["nested"] = {"nkey" => "nvalue"} of String => String
    over = {"otherkey" => "othervalue"} of String => Hash(String, String) | String
    over["nested"] = "avalue"
    b_smash = base.to_smash
    o_smash = over.to_smash
    result = Crogo::Smash.deep_merge(b_smash, o_smash)
    result["nested"].should eq("avalue")
  end

end
