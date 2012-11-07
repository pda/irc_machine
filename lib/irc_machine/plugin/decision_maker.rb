class IrcMachine::Plugin::DecisionMaker < IrcMachine::Plugin::Base

  MAGIC_8_BALL = ["Yes", "No!", "Absopositively", "Hard to say"]
  PREDICATES = %w[
    would should could
    are do if is can will have did
  ]
  def receive_line(line)
    catch(:nomatch) do
      if line =~ decision_prelude
        session.msg $1, generate_reply(line)
      end
    end
  end

  def generate_reply(line)
    case line
    when /:[^:]*:#{session.state.nick}:? (.* or .*)\?$/
      choice($1.split(" or "))
    when /:[^:]*:#{session.state.nick}:? (?:#{PREDICATES.join "|"}).*\?$/
      choice(MAGIC_8_BALL)
    else
      throw(:nomatch)
    end
  end

  def choice(options)
    options.sample
  end

  def decision_prelude
    /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:?/
  end
end
