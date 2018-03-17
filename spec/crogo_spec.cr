require "./spec_helper"

describe Crogo do
  it "should provide a default logger" do
    Crogo.logger.should be_a(Logger)
  end

  it "should allow setting a custom logger" do
    new_logger = Logger.new(STDOUT)
    Crogo.logger.should_not eq(new_logger)
    Crogo.logger = new_logger
    Crogo.logger.should eq(new_logger)
  end
end
