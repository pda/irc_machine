class IrcMachine::Observer::Hello < IrcMachine::Observer::Base
  def receive_line(line)
    session.msg "#irc_machine", "meh" if line =~ /^:\S+ PRIVMSG #irc_machine :hello$/
  end
end
