require "evma_httpserver/response"
require "stringio"

module IrcMachine
  module Plugin
    class Rest < Base

      def start
        EM.start_server "0.0.0.0", 8080, Rest::Server do |c|
          c.router = self
        end
      end

      def route(env)
        request = Rack::Request.new(env)
        route_method = :"route_#{request.request_method.downcase}"
        respond_to?(route_method) ? send(route_method, request) : not_found
      end

      def route_get(request)
        case request.path
        when "/" then ok("root")
        when "/test" then ok("test")
        else not_found
        end
      end

      def route_post(request)
        case request.path

        when %r{/channels/([\w-]+)}
          channel = "#" << $1
          session.join channel unless session.channels.include? channel
          m = request.body.gets
          session.msg "##{$1}", m.chomp if m
          ok "sent message"

        else not_found
        end
      end

      private

      def response(code, content = nil)
        [ code, {}, content ? [ content + "\n" ] : [] ]
      end

      def not_found
        response 404
      end

      def ok(content = nil)
        response 200, content
      end

    end
  end
end
