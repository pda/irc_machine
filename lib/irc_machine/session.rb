module IrcMachine
  class Session
    include Commands

    attr_reader :options
    attr_reader :state
    attr_accessor :irc_connection

    def initialize(options)
      @options = OpenStruct.new(options)
      @state = State.new
      @router = HttpRouter.new(self)
      load_plugins!
    end

    def load_plugins!
      @router.flush_routes!
      @plugins = [Core.new(self)]
      options.plugins.each do |plugin|
        @plugins << Plugin.const_get(plugin).new(self)
      end
    end

    def start
      EM.run do

        signal_traps

        log "Connecting to #{options.server}:#{options.port}"
        EM.connect(
          options.server,
          options.port,
          IrcConnection,
          {:ssl => @options.ssl, :session => self}
        ) do |c|
          self.irc_connection = c
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

    def disconnected
      if @shutdown
        log "Stopping EventMachine"
        EM.stop
      else
        log "Waiting to reconnect"
        EM.add_timer(2) do
          log "Reconnecting to #{options.server}:#{options.port}"
          irc_connection.reconnect options.server, options.port
          @state.reset
          dispatch :connected
        end
      end
    end

    def receive_line(line)
      dispatch :receive_line, line
    end

    def log message
      puts "! " << message if options.verbose
    end

    private

    def dispatch(method, *params)
      @plugins.each { |p| p.send(method, *params) if p.respond_to? method }
    end

    def signal_traps
      Signal.trap("INT") { shutdown }
    end

    def shutdown
      @shutdown = true
      Signal.trap("INT") do
        Signal.trap("INT", "DEFAULT")
        puts "\nStopping EventMachine, interrupt again to force exit"
        EM.stop
      end
      puts "\nQuitting IRC, interrupt again to stop EventMachine"
      dispatch :terminate
    end

  end
end
