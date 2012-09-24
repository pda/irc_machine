class IrcMachine::Plugin::Yarrr < IrcMachine::Plugin::Base
  def receive_line(line)
    Time.now.tap do |today|
      if today.month == 9 && today.day == 19
        if line =~ /^:\S+ PRIVMSG (#+\S+) :.*ya+r+/i
          `ssh saunamacmini ./yarrr.sh &`
        end
      end
    end
  end
end
