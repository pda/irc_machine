class IrcMachine::Plugin::ProgrammingHelper < IrcMachine::Plugin::Base

  QUESTION_PATTERNS = ['how can I',
                       'how do I',
                       "(?:what's|what is) the best way to"]

  HELPFUL_ADVICE = ['Try CMD-Q',
                    'Use node.js',
                    'Use Mongo',
                    'Use babashka',
                    'Have you tried using threads?',
                    'https://github.com/garybernhardt/base',
                    'wat r u doin',
                    'sounds like a devops problem',
                    'sounds like an issue with platform',
                    'RTFM']

  def receive_line(line)
    if line =~ advice_pattern
      session.msg $1, generate_reply
    elsif line =~ /:[^:]*:#{session.state.nick}:? help ([^ ]+)$/
      session.msg $1, generate_reply($2)
    end
  end

  def advice_pattern
    /^:[^:]+:#{session.state.nick}.*\b(?:#{QUESTION_PATTERNS.join('|')})\b.*/i
  end

  def generate_reply(to=nil)
    resp = ""
    resp << "#{to}: " if to
    resp << HELPFUL_ADVICE.sample
    return resp
  end
end
