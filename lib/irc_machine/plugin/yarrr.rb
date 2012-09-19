class IrcMachine::Plugin::Yarrr < IrcMachine::Plugin::Base
  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG (#+\S+) :.*ya+r+/i
      `ssh saunamacmini ./yarrr.sh &`
    end
  end
end
