class IrcMachine::Plugin::Pub < IrcMachine::Plugin::Base
  def receive_line(line)
    now = now_in_straya
    return unless (now.friday? && now.hour == 12)

    if line =~ /^:\S+ PRIVMSG (#+\S+) :.*pub\?/i
      session.msg $1, "Pub."
    end
  end

  def now_in_straya
    # Pretend DST isn't a thing.
    Time.now.getutc + (60 * 60 * 10)
  end
end
