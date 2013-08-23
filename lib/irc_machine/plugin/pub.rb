class IrcMachine::Plugin::Pub < IrcMachine::Plugin::Base

  def receive_line(line)
    return unless (pubtime?(now_in_straya) or pubtime?(now_in_sf))

    if line =~ /^:\S+ PRIVMSG (#+\S+) :.*(pub)\?/i
      session.msg $1, "#{$2}!"
    end
  end

  def pubtime?(time)
    time.friday? && time.hour == 12
  end

  def now_in_straya
    # Pretend DST isn't a thing.
    Time.now.getutc + (60 * 60 * 10)
  end

  def now_in_sf
    # Pretend DST isn't a thing.
    Time.now.getutc - (60 * 60 * 7)
  end
end
