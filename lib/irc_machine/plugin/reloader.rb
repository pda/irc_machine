class IrcMachine::Plugin::Reloader < IrcMachine::Plugin::Base

  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG #{session.nick} :reload$/
      self.class.load_all
    end
  end

  def self.load_all
    files = %w{
      plugin/base
      plugin/die
      plugin/hello
      plugin/ping
      plugin/reloader
      plugin/verbose
      rest
      rest/server
      rest/github_notification
    }.each do |name|
      puts "loading: #{name}"
      load "irc_machine/#{name}.rb"
    end
  end

end
