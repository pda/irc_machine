class IrcMachine::Plugin::Ping < IrcMachine::Plugin::Base
  def receive_line(line)
    session.raw "PONG #{$1}" if line =~ /^PING (.*)/
  end
end
