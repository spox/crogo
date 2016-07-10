require "./spec_helper"

describe Crogo::AnimalStrings do

  it "should snake case camel cased string" do
    Crogo::Utility.snake("CamelCased").should eq("camel_cased")
  end

  it "should camel case snake cased string" do
    Crogo::Utility.camel("snake_cased").should eq("SnakeCased")
  end

  it "should camel case with leading lower case" do
    Crogo::Utility.camel("snake_cased", false).should eq("snakeCased")
  end

end
