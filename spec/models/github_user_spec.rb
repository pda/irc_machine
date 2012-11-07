require File.join(File.dirname(__FILE__), "/../spec_helper")

def stub_user
  { :username => "foo_nick" }
end

describe "Agent99::Models::GithubUser" do

  it "Should lookup from a classlevel mapping" do
    ::IrcMachine::Models::GithubUser.nicks = { "foo_nick" => "nick" }

    gh_user = ::IrcMachine::Models::GithubUser.new(stub_user)
    gh_user.nick.should == "nick"
  end

  it "Should respect prefix from a classlevel mapping" do
    ::IrcMachine::Models::GithubUser.nicks = { "foo_nick" => "nick" }
    ::IrcMachine::Models::GithubUser.prefix = "|"

    gh_user = ::IrcMachine::Models::GithubUser.new(stub_user)
    gh_user.nick.should == "|nick"
  end

end
