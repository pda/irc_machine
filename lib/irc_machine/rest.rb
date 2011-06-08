require "evma_httpserver/response"
require "stringio"

module IrcMachine
  class Rest

    CHANNEL_REGEXP = %r{^/channels/([\w-]+)$}

    def initialize(session)
      @session = session
    end

    attr_reader :session

    def start
      EM.start_server "0.0.0.0", 8421, Rest::Server do |c|
        c.router = self
      end
    end

    def route(env)
      request = Rack::Request.new(env)
      puts "[#{self.class}] << #{request.request_method} #{request.path}"
      route_method = :"route_#{request.request_method.downcase}"
      respond_to?(route_method) ? send(route_method, request) : not_found
    end

    def route_get(request)
      case request.path
      when "/channels"
        [ 200, { "Content-Type" => "application/json" },
          [ session.state.channels.to_json, "\n" ] ]
      else not_found
      end
    end

    def route_post(request)
      case request.path

      when %r{^/channels/([\w-]+)/github$}
        channel = "#" << $1
        session.join channel unless session.state.channel? channel
        session.msg channel, GithubNotification.new(request.body.read).message
        ok

      when CHANNEL_REGEXP
        channel = "#" << $1
        session.join channel unless session.state.channel? channel
        m = request.body.gets
        session.msg channel, m.chomp if m
        ok "sent message"

      else not_found
      end
    end

    def route_put(request)
      case request.path
      when CHANNEL_REGEXP
        session.join "#" << $1
        ok
      end
    end

    def route_delete(request)
      case request.path
      when CHANNEL_REGEXP
        session.part "#" << $1
        ok
      end
    end

    private

    def response(code, content = nil)
      [ code, {}, content ? [ content, "\n" ] : [] ]
    end

    def not_found
      response 404
    end

    def ok(content = nil)
      response 200, content
    end

  end
end
