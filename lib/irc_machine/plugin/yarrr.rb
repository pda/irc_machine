class IrcMachine::Plugin::Yarrr < IrcMachine::Plugin::Base
  def receive_line(line)
    Time.now.tap do |today|
      return unless today.month == 9 && today.day == 19
    end

    if line =~ /^:\S+ PRIVMSG (#+\S+) :.*ya+r+/i
      plugin_send(:Notifier, :notify, "yarr")
    end
  end
end
