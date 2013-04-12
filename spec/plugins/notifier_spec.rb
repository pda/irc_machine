require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "Agent99::Plugin::Notifier" do
  describe "notify" do

    before(:each) do
      @plugin = IrcMachine::Plugin::Notifier.new({})
    end

    it "Should push the event to all connected clients" do
      def @plugin.settings
        { "some_command" => "echo test" }
      end

      @plugin.notify("some_command")
      pending("Mock out a pool and check that they receive the msg")
    end
  end
end
