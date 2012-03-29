module IrcMachine
  class IrcConnection < EM::Connection
    include EM::Protocols::LineText2

    def initialize(opts)
      @ssl = opts[:ssl]
      @session = opts[:session]
    end

    alias_method :orig_post_init, :post_init

    def post_init
      if @ssl
        puts "! Initializing SSL connection"
        @ssl_buffer = ""
        start_tls
      else
        orig_post_init
      end
    end

    def ssl_handshake_completed
      puts "! SSL handshake complete"
      orig_post_init
      buffer = @ssl_buffer
      @ssl_buffer = nil
      send_data buffer
    end

    def send_data(data)
      if @ssl_buffer
        @ssl_buffer << data
      else
        super(data)
      end
    end

    def receive_line(line)
      @session.receive_line(line)
    rescue => e
      puts "!! #{self.class} rescued #{e.inspect}"
      puts "    " + e.backtrace.join("\n    ")
    end

    def unbind
      puts "! Disconnected"
      @session.disconnected
    end
  end
end
