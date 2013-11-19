class IrcMachine::Plugin::Rsvp < IrcMachine::Plugin::Base

  def receive_line(line)
    case line
    when /^:(\S+)+ PRIVMSG (#+\S+) :#{session.state.nick}:? pls2join (#.+)$/
      inviter = $1.chomp
      old_channel = $2.chomp
      new_channel = $3.chomp
      join(old_channel, new_channel, inviter)
    when /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? pls2leave$/
      channel = $1.chomp
      leave(channel)
    end
  end

  def join(old_channel, new_channel, inviter)
    session.msg old_channel, "OK #{inviter}, joining #{new_channel}"
    session.join new_channel
    session.msg new_channel, "Hello. I was invited here by #{inviter}."
  end

  def leave(channel)
    session.msg channel, ':-('
    session.part channel
  end
end
