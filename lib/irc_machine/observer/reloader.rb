class IrcMachine::Observer::Reloader < IrcMachine::Observer::Base
  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG #irc_machine :reload$/
      observers = %w{ base die hello ping reloader verbose }
      puts "reloading " << observers.join(', ')
      observers.each { |name| load "irc_machine/observer/#{name}.rb" }
    end
  end
end
