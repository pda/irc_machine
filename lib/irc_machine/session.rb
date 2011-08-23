module IrcMachine
  class Session
    include Commands

    attr_reader :options
    attr_reader :state
    attr_accessor :irc_connection

    def initialize(options)
      IrcMachine::Plugin::Reloader.load_all

      @options = OpenStruct.new(options)
      @state = State.new
      @router = HttpRouter.new(self)
      @plugins = [
        Core.new(self),
        Plugin::Hello.new(self),
        Plugin::Reloader.new(self),
        Plugin::GithubNotifier.new(self)
      ]
    end

    def start
      EM.run do

        signal_traps

        log "Connecting to #{options.server}:#{options.port}"
        EM.bind_connect(
          options.bind_address,
          nil,
          options.server,
          options.port,
          IrcConnection
        ) do |c|
          self.irc_connection = c
          c.session = self
        end

        log "Starting HTTP API on port #{options.http_port}"
        EM.start_server "0.0.0.0", options.http_port, HttpServer do |c|
          c.router = @router
        end

        log "Starting UDP API on port #{options.udp_port}"
        EM.open_datagram_socket "0.0.0.0", options.udp_port, UdpServer do |c|
          c.session = self
        end

        dispatch :connected
      end
    end

    def receive_line(line)
      dispatch :receive_line, line
    end

    private

    def dispatch(method, *params)
      @plugins.each { |p| p.send(method, *params) if p.respond_to? method }
    end

    def signal_traps
      Signal.trap("INT") { shutdown }
    end

    def shutdown
      Signal.trap("INT") do
        Signal.trap("INT", "DEFAULT")
        puts "\nStopping EventMachine, interrupt again to force exit"
        EM.stop
      end
      puts "\nQuitting IRC, interrupt again to stop EventMachine"
      dispatch :terminate
    end

    def log message
      puts "! " << message if options.verbose
    end

  end
end
