class IrcMachine::Plugin::Reloader < IrcMachine::Plugin::Base
  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG #{session.nick} :reload$/
      self.class.load_all
    end
  end

  def self.load_all
    %w{ base die hello ping reloader verbose rest rest/server }.each do |name|
      puts "reloading observer: #{name}"
      load "irc_machine/plugin/#{name}.rb"
    end
  end
end
