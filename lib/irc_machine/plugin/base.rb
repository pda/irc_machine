module IrcMachine
  module Plugin
    class Base

      def initialize(session)
        if self.class.const_defined?(:CONFIG_FILE)
          initialize_config
        end

        @session = session
        @events = {
          :em_ready => []
        }
      end
      attr_reader :session, :events

      # Inherited from the old HttpController
      def ok(content, opts={})
        Rack::Response.new.tap do |response|
          response.status = 200
          response["Content-Type"] = opts[:content_type] || "text/plain"
          response.write content
        end
      end

      def not_found
        Rack::Response.new.tap do |response|
          response.status = 404
        end
      end

      def redirect(to)
        Rack::Response.new.tap do |response|
          response.redirect(to)
        end
      end

      def route(method, path, destination)
        # Close over the instance method and bind to a route.
        if destination.is_a? Symbol
          sym = destination
          destination = lambda { |request, match| send(sym, request, match) }
        end

        IrcMachine::HttpRouter.send(:connect, method, path, destination)
      end

      def bind(type, port, callback)
        case type
        when :websocket
          events[:em_ready] << Proc.new {
            opts = { :host => '0.0.0.0', :port => port }
            EventMachine::start_server(opts[:host], opts[:port], EventMachine::WebSocket::Connection, opts) do |c|
              callback.call(c)
            end
          }
        end
      end

      def plugin_send(plugin, sym, *args)
        if (p = session.get_plugin plugin)
          p.send(sym, *args)
        end
      end

      def em_ready
        events[:em_ready].each do |event|
          event.call
        end
      end


      def deinitialize
      end

    protected

      def initialize_config
        class << self
          define_method(:settings) do
            @settings ||= load_config
          end
        end
      end

      def load_config
        JSON.load(open(File.expand_path(self.class.const_get(:CONFIG_FILE))))
      end

    end
  end
end
