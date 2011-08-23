class IrcMachine::Plugin::Reloader < IrcMachine::Plugin::Base

  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG #{session.state.nick} :reload$/
      self.class.load_all
    end
  end

  def self.load_all
    files = %w{
      core
      core_routes

      udp_server

      http_controller
      http_router
      http_server

      controller/channels_controller
      controller/github_notifications_controller

      plugin/github_notifier
      plugin/base
      plugin/hello
      plugin/reloader
    }.each do |name|
      puts "loading: #{name}"
      load "irc_machine/#{name}.rb"
    end
  end

end
