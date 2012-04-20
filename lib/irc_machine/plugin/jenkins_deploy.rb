class IrcMachine::Plugin::JenkinsNotify < IrcMachine::Plugin::Base

  CONFIG_FILE = "jenkins_notify.json"

  def initialize(*args)
    @apps = load_config
    super(*args)
  end
  attr_reader :apps

  def receive_line(line)
    # TODO Regex
    if line =~ /^:(\S+)@\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? deploy (\S+)$/
      deployer = $1
      channel = $2
      repo = $3

      session.msg channel, "Deploying \\o/"
    end
  end

  private

  def load_config
    OpenStruct.new(JSON.load(open(File.expand_path(CONFIG_FILE))))
  end

end
