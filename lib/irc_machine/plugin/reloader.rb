class IrcMachine::Plugin::Reloader < IrcMachine::Plugin::Base

  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG #{session.state.nick} :reload$/
      self.class.load_all
    end
  end

  def self.load_all
    files = %w{
      core_routes
      core
      http_dispatcher
      http_router
      http_server
      plugin/github_notification
      plugin/base
      plugin/die
      plugin/hello
      plugin/reloader
    }.each do |name|
      puts "loading: #{name}"
      load "irc_machine/#{name}.rb"
    end
  end

end
