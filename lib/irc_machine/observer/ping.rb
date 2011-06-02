class IrcMachine::Observer::Ping < IrcMachine::Observer::Base
  def receive_line(line)
    session.raw "PONG #{$1}" if line =~ /^PING (.*)/
  end
end
