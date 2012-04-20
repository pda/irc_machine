class Apps
  CONFIG_FILE = "jenkins_notify.json"

  def initialize(appname)
    conf = JSON.load(open(File.expand_path(CONFIG_FILE)))
  end

end





class IrcMachine::Plugin::JenkinsNotify < IrcMachine::Plugin::Base

  def initialize(*args)
    @apps = []
    super(*args)
  end

  def receive_line(line)
    # TODO Regex
    if line =~ /^:(\S+)@\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? deploy (\S+)$/
      deployer = $1
      channel = $2
      repo = $3

      session.msg channel, "Deploying \\o/"
    end
  end

end
