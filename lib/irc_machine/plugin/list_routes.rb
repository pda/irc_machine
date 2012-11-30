require 'json'
require 'net/http'

class IrcMachine::Plugin::ListRoutes < IrcMachine::Plugin::Base

  def initialize(session)
    @session = session
    super
    route :get, %r{^/$}, :list_routes
  end

  def list_routes(request, match)
    ok @session.router.describe_patterns.map {|k, v| "#{k}: #{v.inspect}"}.join("\n")
  end

end
