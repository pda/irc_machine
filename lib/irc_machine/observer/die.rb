class IrcMachine::Observer::Die < IrcMachine::Observer::Base
  def receive_line(line)
    if line =~ /^:(\S+)!\S+@\S+ PRIVMSG #irc_machine :die$/
      session.quit "killed by #{$1}"
    end
  end
end
