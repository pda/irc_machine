require "evma_httpserver/response"
require "stringio"

module IrcMachine
  class HttpRouter

    def initialize(session)
      @session = session
      @routes = { get: [], put: [], delete: [], post: [] }
    end

    def route(env)
      request = Rack::Request.new(env)
      response = HttpDispatcher.new(self, @session, @routes, request).dispatch
      response.finish
    end

    def get(route, &block); connect :get, route, &block; end
    def put(route, &block); connect :put, route, &block; end
    def delete(route, &block); connect :delete, route, &block; end
    def post(route, &block); connect :post, route, &block; end

    def connect(method, pattern, &block)
      @routes[method] << [ pattern, block ]
    end

    def draw(&block)
      instance_eval &block
    end

    def helpers(&block)
      instance_eval &block
    end

  end
end
