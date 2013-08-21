require 'spec_helper'

describe "Agent99::Plugin::JuiciDownstream" do
  describe "callbacks" do

    before(:each) do
      @plugin = IrcMachine::Plugin::JuiciDownstream.new({})
      def @plugin.settings
        { "callback_base" => "http://agent99.99cluster.example.com"}
      end
    end

    it "generates callbacks" do
      cb = @plugin.new_callback
      cb[:url].to_s.should start_with "http://agent99.99cluster.example.com/juici/build_project/"
    end

  end
end
