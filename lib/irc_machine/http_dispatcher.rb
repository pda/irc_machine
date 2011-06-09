module IrcMachine
  class HttpDispatcher

    def initialize(router, session, routes, request)
      @router = router
      @session = session
      @routes = routes
      @request = request
      @response = Rack::Response.new
    end

    attr_reader :session
    attr_reader :request, :response

    def dispatch
      if route_match.block
        instance_exec route_match.match, &route_match.block
      else
        not_found
      end
      @response
    end

    private

    def route_match
      @route_match ||= lookup_route_match
    end

    def lookup_route_match
      # this is pretty bad..
      route_match = OpenStruct.new
      _, route_match.block = @routes[method].detect do |(pattern,block)|
        if pattern.is_a? Regexp
          route_match.match = pattern.match(path)
        else
          route_match.match = nil
          pattern == path
        end
      end
      route_match
    end

    def method
      request.request_method.downcase.to_sym
    end

    def path
      request.path
    end

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

    # Send helper method calls to HttpRouter.
    def method_missing(method, *params)
      @router.send(method, *params)
    end

  end
end
