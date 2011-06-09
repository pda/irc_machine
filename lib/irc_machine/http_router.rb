require "evma_httpserver/response"
require "stringio"

module IrcMachine
  class HttpRouter

    def initialize(session)
      @session = session
      @routes = { get: [], put: [], delete: [], post: [] }
    end

    attr_reader :session
    attr_reader :request

    def route(env)
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      method = request.request_method.downcase.to_sym
      path = request.path
      match = nil

      _, block = @routes[method].detect do |(pattern,block)|
        if pattern.is_a? Regexp
          match = pattern.match(path)
        else
          match = nil
          pattern == path
        end
      end

      if block
        block.call(match)
      else
        not_found
      end

      @response.finish
    end

    def get(route, &block); connect :get, route, &block; end
    def put(route, &block); connect :put, route, &block; end
    def delete(route, &block); connect :delete, route, &block; end
    def post(route, &block); connect :post, route, &block; end

    def connect(method, pattern, &block)
      puts "#{method.upcase} #{pattern}"
      @routes[method] << [ pattern, block ]
    end

    def draw(&block)
      instance_eval &block
    end

    def helpers(&block)
      instance_eval &block
    end

    private

    def not_found
      @response.status = 404
    end

    def ok(content)
      @response.status = 200
      @response.write content
    end

    def content_type(type)
      @response["Content-Type"] = type
    end

  end
end
