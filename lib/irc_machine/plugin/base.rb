module IrcMachine
  module Plugin
    class Base
      def initialize(session)
        if self.class.const_defined?(:CONFIG_FILE)
          initialize_config
        end

        @session = session
      end
      attr_reader :session

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

      def plugin_send(plugin, sym, *args)
        if (p = session.get_plugin plugin)
          p.send(sym, *args)
        end
      end

    protected

      def initialize_config
        class << self
          define_method(:settings) do
            @settings ||= load_config
          end

          define_method(:load_config) do
            JSON.load(open(File.expand_path(CONFIG_FILE)))
          end
        end
      end

    end
  end
end
