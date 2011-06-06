class IrcMachine::Plugin::Hello < IrcMachine::Plugin::Base
  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG (#+\S+) :hello$/
      session.msg $1, "world"
    end
  end
end
