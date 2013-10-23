class IrcMachine::Plugin::Karma < IrcMachine::Plugin::Base

  KARMA_SPEND_RATIO = 0.95
  KARMA_INCREMENT_AMOUNT = 1
  INITIAL_KARMA_AMOUNT = 10

  def receive_line(line)
    if line =~ /^:(\S+) PRIVMSG (#+\S+) :@(\S+)\+\+$/
      send_karma($1, $3)
    end
  end

  def send_karma(from, to)
    karma[from] *= KARMA_SPEND_RATIO
    karma[to] += KARMA_INCREMENT_AMOUNT
  end

  def karma
    @karma ||= Hash.new do |h, k|
      h[k] = INITIAL_KARMA_AMOUNT
    end
  end

end
