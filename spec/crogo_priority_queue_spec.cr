require "./spec_helper"

describe Crogo::PriorityQueue do
  it "should create a new PriorityQueue of Strings" do
    queue = Crogo::PriorityQueue(String).new
    queue.is_a?(Crogo::PriorityQueue(String)).should be_true
  end

  it "should return queue when pushing" do
    queue = Crogo::PriorityQueue(String).new
    r_val = queue.push("test", 1)
    r_val.should eq(queue)
  end

  it "should allow pushing array of value and cost tuples" do
    queue = Crogo::PriorityQueue(String).new
    vals = [{"val1", 1}, {"val2", 2}, {"val3", 3}]
    queue.multi_push(vals)
    queue.pop.should eq(vals.first.first)
  end

  it "should delete item from queue" do
    queue = Crogo::PriorityQueue(String).new
    vals = [{"val1", 1}, {"val2", 2}, {"val3", 3}]
    queue.multi_push(vals)
    queue.delete("val1")
    queue.pop.should eq("val2")
  end

  context "using default style" do
    it "should return value with lowest score" do
      queue = Crogo::PriorityQueue(String).new
      queue.push("top", 3).push("lowscore", 1).push("highscore", 2)
      queue.pop.should eq("lowscore")
    end

    it "should return value with lowest score defined by block" do
      queue = Crogo::PriorityQueue(String).new
      queue.push("highscore", 2).push("lowscore"){ 1 }.push("top", 3)
      queue.pop.should eq("lowscore")
    end
  end

  context "using highscore value" do
    it "should return value with highest score" do
      queue = Crogo::PriorityQueue(String).new(:highscore)
      queue.push("top", 3).push("lowscore", 1).push("highscore", 2)
      queue.pop.should eq("top")
    end

    it "should return value with highest score defined by block" do
      queue = Crogo::PriorityQueue(String).new(:highscore)
      queue.push("highscore", 2).push("lowscore"){ 1 }.push("top", 3)
      queue.pop.should eq("top")
    end
  end

  context "dynamic block costs" do
    it "should re-sort when using blocks" do
      val1 = [1, 2]
      val2 = [2, 1]
      queue = Crogo::PriorityQueue(String).new
      queue.push("val1"){ val1.shift }.push("val2"){ val2.shift }.push("val0", 0)
      queue.pop.should eq("val0")
      queue.pop.should eq("val2")
    end
  end
end
