module IrcMachine
  class Session
    include Commands

    attr_reader :connection

    def initialize(options)
      @server, @port = defaults.merge(options).values_at(:server, :port)
      IrcMachine::Plugin::Reloader.load_all
      @plugins = [
        Plugin::Verbose.new(self),
        Plugin::Die.new(self),
        Plugin::Hello.new(self),
        Plugin::Ping.new(self),
        Plugin::Reloader.new(self),
        Plugin::Rest.new(self)
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
        @plugins.each do |plugin|
          plugin.start if plugin.respond_to?(:start)
        end
      end
    end

    def post_connect
      user "irc_machine", "irc machine"
      nick "irc_machine"
      join "#irc_machine"
    end

    def receive_line(line)
      @plugins.each do |plugin|
        plugin.receive_line(line) if plugin.respond_to?(:receive_line)
      end
    end

    def defaults
      { port: 6667 }
    end

  end
end
