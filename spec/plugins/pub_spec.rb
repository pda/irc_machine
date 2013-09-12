require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "Agent99::Plugin::Pub" do
  describe "pub" do
    before(:each) do
      @session = stub_session
      @plugin = IrcMachine::Plugin::Pub.new(@session)
    end

    it "should reply pub when it's pubtime" do
      @session.expects(:msg).with("#hacks", "pub.")
      @plugin.stubs(:now_in_straya).returns Time.new(2013, 4, 19, 12, 35, 00, "+10:00")
      @plugin.receive_line(":richo PRIVMSG #hacks :is it time for pub?")
    end

    it "should be quiet when it's not time for the pub" do
      @plugin.stubs(:now_in_straya).returns Time.new(2013, 4, 19, 14, 35, 00, "+10:00")
      @plugin.receive_line(":richo PRIVMSG #hacks :is it time for pub?")
    end
  end
end
