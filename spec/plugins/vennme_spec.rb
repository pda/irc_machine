require 'spec_helper'

describe "Agent99::Plugin::VennMe" do
  before(:each) do
    @plugin = IrcMachine::Plugin::VennMe.new({})
  end

  it "Should parse strings" do
    match = @plugin.parse("(rawr (foo) butts)")
    match[1].should == "rawr "
    match[2].should == "foo"
    match[3].should == " butts"
  end

  it "Should return nil for invalid strings" do
    @plugin.parse("(rawr foo barr").should be_nil
  end

  it "Should create correct urls" do
    correct_url = "http://vennme.herokuapp.com/up?a=200&b=200&ab=110&alabel=rawr&ablabel=butts&blabel=foo"
    @plugin.venn_me("(rawr (butts)   foo)").should == correct_url
  end

end
