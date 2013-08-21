require 'spec_helper'

describe 'IrcMachine::Plugin::Reactionify' do

  before(:each) do
    @session = stub_session
    @plugin = IrcMachine::Plugin::Reactionify.new(@session)
  end

  it 'should ask Reactionifier for GIF URLs' do
    gif_url = 'http://example.com/foo.gif'
    Reactionifier::Reactionifier.any_instance.stubs(:reaction_gif => gif_url)
    @plugin.reaction_gif('derp').should eq gif_url
  end

  it 'should reply when a GIF is found' do
    gif_url = 'http://example.com/foo.gif'
    @plugin.stubs(:reaction_gif => gif_url)
    @session.expects(:msg).with('#derp', gif_url)
    @plugin.receive_line(":bla PRIVMSG #derp :#{stub_nick}: reactionify something")
  end

  it 'should not reply when no GIF is found' do
    @plugin.stubs(:reaction_gif => nil)
    @plugin.receive_line(":bla PRIVMSG #derp :#{stub_nick}: reactionify some other thing")
  end
end
