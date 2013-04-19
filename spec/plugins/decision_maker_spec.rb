require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "Agent99::Plugin::DecisionMaker" do
  describe "generate_reply" do
    before(:each) do
      @session = stub_session
      @plugin = IrcMachine::Plugin::DecisionMaker.new(@session)
    end

    it "should return one of your choices when given a list" do
      IrcMachine::Plugin::DecisionMaker::MAGIC_8_BALL.should include(
        @plugin.generate_reply(":rawr:#{stub_nick}: is it beer time?")
      )
    end

    it "should give smartass answers to questions about when" do
      IrcMachine::Plugin::DecisionMaker::DATE_REPLIES.should include(
        @plugin.generate_reply(":rawr:#{stub_nick}: when should we do R&D wrap up?")
      )
    end

    it "should return one of the choices given" do
      ["beer", "wine", "spirits"].should include(
        @plugin.generate_reply(":rawr:#{stub_nick}: beer or wine or spirits?")
      )
    end

    it "should cope with spaces in the options given" do
      ["do this", "do that"].should include(
        @plugin.generate_reply(":rawr:#{stub_nick}: do this or do that?")
      )
    end

    it "should throw :nomatch when nothing matches" do
      lambda {
        @plugin.generate_reply(":rawr:foobar")
      }.should throw_symbol(:nomatch)
    end

  end
end
