module IrcMachine
  class Session
    include Commands

    attr_reader :options
    attr_reader :connection

    def initialize(options)
      @options = defaults.merge(options)

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
        EM.connect options[:server], options[:port], Connection do |c|
          self.connection = c
          post_connect
        end
        @plugins.each do |plugin|
          plugin.start if plugin.respond_to?(:start)
        end
      end
    end

    def post_connect
      user options[:user], options[:realname]
      nick options[:nick]
      options[:channels].each { |c| join c } if options[:channels]
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
