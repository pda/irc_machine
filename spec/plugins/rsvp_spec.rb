require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'IrcMachine::Plugin::Rsvp' do
  before(:each) do
    @session = stub_session
    @plugin = IrcMachine::Plugin::Rsvp.new(@session)
  end

  describe 'receive_line' do
    it 'should join channels when asked' do
      @session.expects(:msg).with('#boring', 'OK joebloggs, joining #exciting')
      @session.expects(:join).with('#exciting')
      @session.expects(:msg).with('#exciting', "Hello. I was invited here by joebloggs.")
      @plugin.receive_line ':joebloggs PRIVMSG #boring :agent99 pls2join #exciting'
    end

    it 'should leave channels when asked' do
      @session.expects(:msg).with('#exciting', ':-(')
      @session.expects(:part).with('#exciting')
      @plugin.receive_line ':joebloggs PRIVMSG #exciting :agent99 pls2leave'
    end
  end
end
