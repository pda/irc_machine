module IrcMachine
  class HttpController

    def self.dispatch(session, request, method, match)
      new(session, request, match).tap do |c|
        c.send method
      end.response
    end

    def initialize(session, request, match)
      @session = session
      @request = request
      @match = match
      @response = Rack::Response.new
    end

    attr_reader :session
    attr_reader :request, :response
    attr_reader :match

    def ok(content)
      @response.status = 200
      @response.write content
    end

    def not_found
      @response.status = 404
    end

    def content_type(type)
      @response["Content-Type"] = type
    end

  end
end
