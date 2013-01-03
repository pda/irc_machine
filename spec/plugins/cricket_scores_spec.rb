require 'spec_helper'

describe "Agent99::Plugin::CricketScores" do
  before(:each) do
    @plugin = IrcMachine::Plugin::CricketScores.new({})
    @plugin.cricket_feed_url = File.join(File.dirname(__FILE__), '..', 'fixtures', 'sample_cricket_scores.xml')
  end

  it "outputs cricket scores" do
    @plugin.cricket_scores.should == "AUS vs SL - Day 1: Post Lunch Session\nSL 133/2"
  end

end
