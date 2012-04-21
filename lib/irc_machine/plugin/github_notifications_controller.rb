class IrcMachine::Plugin::GithubNotification < IrcMachine::Plugin::Base

  def initialize(*args)
    route(:post, %r{^/channels/([\w-]+)/github$}, :notify)
    super(*args)
  end

  def notify
    session.msg "##{match[1]}",
      ::IrcMachine::Models::GithubNotification.new(request.body.read).message
  end

end
