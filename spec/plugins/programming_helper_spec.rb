require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'IrcMachine::Plugin::ProgrammingHelper' do
  before(:each) do
    @session = stub_session
    @plugin = IrcMachine::Plugin::ProgrammingHelper.new(@session)
  end

  describe 'generate_reply' do
    it 'should generate helpful advice' do
      IrcMachine::Plugin::ProgrammingHelper::HELPFUL_ADVICE.should include(
        @plugin.generate_reply
      )
    end
  end

  describe 'advice_pattern' do
    it 'should match relevant questions' do
      ":butts PRIVMSG #derp :hello, how can I PHP?".should match @plugin.advice_pattern
    end

    it 'should not match irrelevant input' do
      ":butts PRIVMSG #derp :hello".should_not match @plugin.advice_pattern
    end
  end
end
