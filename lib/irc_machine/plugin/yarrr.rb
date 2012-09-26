class IrcMachine::Plugin::Yarrr < IrcMachine::Plugin::Base
  def receive_line(line)
    Time.now.tap do |today|
      if today.month == 9 && today.day == 19
        if line =~ /^:\S+ PRIVMSG (#+\S+) :.*ya+r+/i
          plugin_send(:Notifier, :notify, "yarr")
        end
      end
    end
  end
end
