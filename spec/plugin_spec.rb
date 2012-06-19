require File.join(File.dirname(__FILE__), "/spec_helper")

describe "Agent99::Plugin" do
  # Message passing in agent99 is dependant on the actual classname of the
  # plugin. This we can't go nuts with mocks
  it "Should pass messages to other plugins" do
    class IrcMachine::Plugin::Plugin1 < IrcMachine::Plugin::Base
    end

    class IrcMachine::Plugin::Plugin2 < IrcMachine::Plugin::Base
      def send_to_1
        plugin_send(:Plugin1, :test_method, "rawp")
      end
    end

    options = {
      "plugins" => ["Plugin1", "Plugin2"]
    }

    class IrcMachine::Session
      def plugins
        @plugins
      end
    end

    session = IrcMachine::Session.new(options)
    session.plugins.length.should == 3
    # Test we can get plugins
    session.plugin_by_name(:Plugin1).class.should == IrcMachine::Plugin::Plugin1
    session.plugin_by_name(:Plugin1).expects(:test_method).with("rawp")
    session.plugin_by_name(:Plugin2).send_to_1
  end
end

