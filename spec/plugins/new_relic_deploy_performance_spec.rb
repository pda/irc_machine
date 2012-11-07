require 'spec_helper'

describe "Agent99::Plugin::NewRelicDeployPerformance" do
  describe "report_timing" do

    before(:each) do
      @plugin = IrcMachine::Plugin::NewRelicDeployPerformance.new({})
      def @plugin.settings
        { "api_key" => "key", "account_id" => "acct", "applications" => {"foo" => 1} }
      end
    end

    it "reports missing applications" do
      expected_msg = "Unknown app 'unknown_app_name'; I know about [\"foo\"]"
      @plugin.report_timing_message("unknown_app_name").should == expected_msg
    end

    it "fetches data from new relic" do
      sample_json_response = <<-JSON
        [{"name":"EndUser/Apdex","app":"contests","agent_id":184089,"score":0.81}]
      JSON
      RestClient::Resource.any_instance.stubs(:get).returns sample_json_response

      @plugin.report_timing_message("foo").should == "foo apdex 5 minutes ago: 0.81"
    end
  end
end
