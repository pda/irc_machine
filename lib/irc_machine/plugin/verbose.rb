class IrcMachine::Plugin::Verbose < IrcMachine::Plugin::Base
  def receive_line(line)
    # output server input except MOTD
    puts "<< #{line}" unless line =~ /^:[\S]+ 372 /
  end
end
