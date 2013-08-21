require 'reactionifier'

class IrcMachine::Plugin::Reactionify < IrcMachine::Plugin::Base

  def initialize(*args)
    super(*args)
    @reactionifier = ::Reactionifier::Reactionifier.new
  end

  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? reactionify (.*)$/
      if gif = reaction_gif($2)
        session.msg($1, gif)
      end
    end
  end

  def reaction_gif(mood)
    @reactionifier.reaction_gif(mood)
  end
end
