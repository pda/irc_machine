require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "Agent99::Plugin::Karma" do
  describe "notify" do

    klass = IrcMachine::Plugin::Karma

    before(:each) do
      @plugin = IrcMachine::Plugin::Karma.new({})
    end

    it "Should start users with #{klass::INITIAL_KARMA_AMOUNT} karma" do
      @plugin.karma["richo"].should == klass::INITIAL_KARMA_AMOUNT
    end

    it "Should let users adjust karma" do
      @plugin.receive_line(":richo PRIVMSG #hax :@brad++")
      @plugin.karma["richo"].should == klass::INITIAL_KARMA_AMOUNT * klass::KARMA_SPEND_RATIO
      @plugin.karma["brad"].should == klass::INITIAL_KARMA_AMOUNT + klass::KARMA_INCREMENT_AMOUNT
    end

  end
end
