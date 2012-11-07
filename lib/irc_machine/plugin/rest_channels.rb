class IrcMachine::Plugin::RestChannels < IrcMachine::Plugin::Base

  CHANNEL_REGEXP ||= %r{^/channels/([\w-]+)$}
  # Ditch the constant for reloadable code or bear the
  # consequences

  # Can ditch dependence on instance if we load data
  # from the FS on each request?

  # Looping args through is ugly, but it needs to be
  # instance specific
  def initialize(*args)
    route(:get, "/channels", :list)
    route(:put, CHANNEL_REGEXP, :join)
    route(:delete, CHANNEL_REGEXP, :part)
    route(:post, CHANNEL_REGEXP, :message)
    super(*args)
  end

  def list(request, match)
    ok session.state.channels.to_json << "\n",
      content_type: "application/json"
  end

  def join(request, match)
    session.join channel(match), request.GET["key"]
  end

  def part(request, match)
    session.part channel(match)
  end

  def message(request, match)
    input = request.body.gets
    source = request.env["HTTP_X_AUTH"] || request.ip || "unknown"
    session.msg channel(match), "[#{source}] #{input.chomp}" if input
  end

  private

  def channel(match)
    "#" + match[1]
  end

end
