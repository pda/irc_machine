require File.join(File.dirname(__FILE__), "/../spec_helper")

def stub_nick
  "agent99"
end

def stub_state
  mock.tap do |state|
    state.stubs(:nick).returns(stub_nick)
  end
end

def stub_session
  mock.tap do |session|
    session.stubs(:state).returns(stub_state)
  end
end

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

    it "should return one of the choices given" do
      ["beer", "wine", "spirits"].should include(
        @plugin.generate_reply(":rawr:#{stub_nick}: beer or wine or spirits?")
      )
    end

    it "should throw :nomatch when nothing matches" do
      lambda {
        @plugin.generate_reply(":rawr:foobar")
      }.should throw_symbol(:nomatch)
    end

  end
end
