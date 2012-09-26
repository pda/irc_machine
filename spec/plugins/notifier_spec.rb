require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "Agent99::Plugin::Notifier" do
  describe "notify" do

    before(:each) do
      @plugin = IrcMachine::Plugin::Notifier.new({})
    end

    it "Should run a single shell command" do
      def @plugin.settings
        { "some_command" => "echo test" }
      end

      Kernel.expects(:system).with("echo test &")
      @plugin.notify("some_command")
    end

    it "Should run all shell commands in an array" do
      def @plugin.settings
        { "some_other_command" => [
            "echo rawr",
            "echo beep"
        ]}
      end

      Kernel.expects(:system).with("echo rawr &")
      Kernel.expects(:system).with("echo beep &")
      @plugin.notify("some_other_command")
    end
  end
end
