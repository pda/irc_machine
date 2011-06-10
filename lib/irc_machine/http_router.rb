require "evma_httpserver/response"
require "stringio"

module IrcMachine
  class HttpRouter

    include CoreRoutes

    def initialize(session)
      @session = session
      @routes = { get: [], put: [], delete:[], post: [] }
      draw_routes
    end

    def route(env)
      request = Rack::Request.new(env)

      match = lookup_route_match(request.request_method, request.path)

      response = case match.destination
      when String
        name, method = match.destination.split("#")
        IrcMachine::Controller.const_get(name).dispatch(@session, request, method, match.match)
      else
        puts "Unhandled route destination type: #{match.destination.class}"
      end

      response.finish
    end

    def get(route, destination); connect :get, route, destination; end
    def put(route, destination); connect :put, route, destination; end
    def delete(route, destination); connect :delete, route, destination; end
    def post(route, destination); connect :post, route, destination; end

    def connect(method, pattern, destination)
      @routes[method] << [ pattern, destination ]
    end

    private

    def lookup_route_match(request_method, path)
      # this is pretty bad..
      request_method = request_method.downcase.to_sym
      route_match = OpenStruct.new
      _, route_match.destination = @routes[request_method].detect do |(pattern,destination)|
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
