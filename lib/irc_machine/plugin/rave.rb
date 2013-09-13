require 'meminator'

class IrcMachine::Plugin::Rave < IrcMachine::Plugin::Base

  def receive_line(line)
    if line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? transformers rave$/
      session.msg $1, "http://i.imgur.com/lHgEm.gif"
    end
  end

end
