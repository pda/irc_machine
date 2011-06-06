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
        when "/channels/irc_machine"
          m = request.body.gets
          session.msg "#irc_machine", m.chomp if m
          ok "sent message"
        else not_found
        end
      end

      private

      def error(code, content = nil)
        [ code, {}, content ? [ content + "\n" ] : [] ]
      end

      def not_found
        error 404
      end

      def ok(content)
        [ 200, {}, [ content + "\n" ] ]
      end

    end
  end
end
