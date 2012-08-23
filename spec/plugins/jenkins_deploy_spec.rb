require File.join(File.dirname(__FILE__), "/../spec_helper")

def jenkins_notify_config
  { :Fixture => { :deploy_url => "http://jenkins.test/deploy",
                   :auto_deploy => "FixtureBranch" }
  }
end

describe "Agent99::Plugin::JenkinsNotify" do
  describe "autocommit" do
    before(:each) do #{{{
      IrcMachine::Plugin::JenkinsNotify.any_instance.stubs(:load_config).returns(jenkins_notify_config)
      @plugin = IrcMachine::Plugin::JenkinsNotify.new({})
      def @plugin.apps
        @apps
      end
    end #}}}

    it "Should autodeploy when the integration branch passes" do

      app = @plugin.apps["Fixture"]
      callback = mock
      commit = Fixtures::GithubCommit.new
      callback.expects(:call).at_least(2)
      app.expects(:deploy!)
      @plugin.build_success(commit, nil, callback)
    end
  end
end
