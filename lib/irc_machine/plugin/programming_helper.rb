class IrcMachine::Plugin::ProgrammingHelper < IrcMachine::Plugin::Base

  QUESTION_PATTERNS = ['how can I',
                       'how do I',
                       "(?:what's|what is) the best way to"]

  HELPFUL_ADVICE = ['Try CMD-Q',
                    'Use node.js',
                    'Use Mongo',
                    'Have you tried using threads?',
                    'https://github.com/garybernhardt/base',
                    'wat r u doin']

  def receive_line(line)
    if line =~ advice_pattern
      session.msg $1, generate_reply
    end
  end

  def advice_pattern
    /^:\S+ PRIVMSG (#+\S+) :.*\b(?:#{QUESTION_PATTERNS.join('|')})\b.*/i
  end

  def generate_reply
    HELPFUL_ADVICE.sample
  end
end
