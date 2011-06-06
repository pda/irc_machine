class IrcMachine::Plugin::Die < IrcMachine::Plugin::Base
  def receive_line(line)
    if line =~ /^:(\S+)!\S+@\S+ PRIVMSG #{session.nick} :die$/
      session.quit "killed by #{$1}"
    end
  end
end
