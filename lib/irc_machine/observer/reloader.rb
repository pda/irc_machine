class IrcMachine::Observer::Reloader < IrcMachine::Observer::Base
  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG #irc_machine :reload$/
      %w{ base die hello ping reloader verbose }.each do |name|
        puts "reloading observer: #{name}"
        load "irc_machine/observer/#{name}.rb"
      end
    end
  end
end
