require "evma_httpserver/response"
require "stringio"

module IrcMachine
  class HttpRouter

    @@routes = { get: [], put: [], delete:[], post: [] }

    class << self

      def connect(method, pattern, destination)
        @@routes[method] << [ pattern, destination ]
      end

    end

    def initialize(session)
      @session = session
    end
    attr_reader :session

    def route(env)
      request = Rack::Request.new(env)

      match = lookup_route_match(request.request_method, request.path)

      puts "%s %s %s => %s" % [
        self.class,
        request.request_method,
        request.path,
        # TODO Lambda's don't inspect tremendously well
        match.destination.inspect
      ]

      response = case match.destination
      when nil
        Rack::Response.new "Unhandled destination: #{match.destination.class}", 500
      else
        match.destination.call(request, match.match)
      end

      unless response.is_a? Rack::Response
        response = Rack::Response.new "", 204
      end
      response.finish
    end

    def flush_routes!
      @@routes.each do |k, v|
        @@routes[k] = []
      end
    end

    private

    def lookup_route_match(request_method, path)
      # this is pretty bad..
      request_method = request_method.downcase.to_sym
      route_match = OpenStruct.new
      _, route_match.destination = @@routes[request_method].detect do |(pattern,destination)|
        if pattern.is_a? Regexp
          route_match.match = pattern.match(path)
        else
          route_match.match = nil
          pattern == path
        end
      end
      route_match
    end

  end
end
