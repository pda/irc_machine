module IrcMachine
  class Session
    include Commands

    attr_reader :connection

    def initialize(options)
      @server, @port = defaults.merge(options).values_at(:server, :port)
      @observers = [
        Observer::Verbose.new(self),
        Observer::Die.new(self),
        Observer::Hello.new(self),
        Observer::Ping.new(self),
        Observer::Reloader.new(self)
      ]
      @publishers = [
        Publisher::Rest.new(self)
      ]
    end

    def connection=(c)
      c.session = self
      @connection = c
    end

    def start
      EM.run do
        EM.connect @server, @port, Connection do |c|
          self.connection = c
          post_connect
        end
        @publishers.each &:start
      end
    end

    def post_connect
      user "irc_machine", "irc machine"
      nick "irc_machine"
      join "#irc_machine"
    end

    def receive_line(line)
      @observers.each do |o|
        o.receive_line(line) if o.respond_to?(:receive_line)
      end
    end

    def defaults
      { port: 6667 }
    end

  end
end
