require 'net/http'
class MutexApp
  attr_reader :name, :last_user
  attr_accessor :deploy_url

  def initialize(name)
    @name = name
    @cache = { channel: "" }
    @deploying = false
    @last_user = "agent99"
    @last_state = :initial
    @deploy_lock = Mutex.new

    if block_given?
      yield self
    end
  end

  def deploy!(user, channel)
    # Reactor model, this is safe
    return "Deploy for #{name} in progress by #{last_user}" if @deploying

    @deploying = true
    @last_state = :deploying
    @last_user = user
    @cache[:channel] = channel

    uri = URI(deploy_url)
    Net::HTTP.get(uri)

    return "Deploy started for #{name}"
  end

  def succeed
    last_deploying = @deploying
    @last_state = :successful
    @deploying = false
    return last_deploying
  end

  def fail
    last_deploying = @deploying
    @last_state = :failure
    @deploying = false
    return last_deploying
  end

  def last_state
    @last_state.to_s
  end

  def last_channel
    @cache[:channel]
  end

  def deploying?
    @deploying
  end

end

class SymbolicHash < Hash
  def [](k)
    super k.to_sym
  end
end

class IrcMachine::Plugin::JenkinsNotify < IrcMachine::Plugin::Base

  CONFIG_FILE = "jenkins_notify.json"
  SQUIRRELS = %w[
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/ship%20it%20squirrel.png
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/squirrel.png
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/Ship%20it1.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/Ship%20it2.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/squirrels.jpg
  ]


  def initialize(*args)
    @apps = SymbolicHash.new
    load_config.each do |k, v|
      @apps[k] = MutexApp.new(k) do |app|
        app.deploy_url = v[:deploy_url]
      end

      route(:get, %r{/deploy/(#{k})/success}, :rest_success)
      route(:get, %r{/deploy/(#{k})/fail}, :rest_fail)

    end

    super(*args)
  end
  attr_reader :apps

  def receive_line(line)
    # TODO Regex
    if line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? deploy (\S+)$/
      user = $1.chomp
      channel = $2.chomp
      repo = $3.chomp

      app = apps[repo.to_sym]
      if app.nil?
        session.msg channel, "Unknown repo: #{repo}"
      else
        deploy(app, user, channel)
      end

    elsif line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? status (\S+)$/
      user = $1.chomp
      channel = $2.chomp
      repo = $3.chomp

      app = apps[repo.to_sym]
      if app.nil?
        session.msg channel, "Unknown repo: #{repo}"
      else
        if app.deploying?
          session.msg channel, "#{user}: #{repo} is currently being deployed by #{app.last_user}"
        else
          session.msg channel, "#{user}: #{repo} is not currently being deployed"
        end
      end
    end
  end

  def rest_success(request, match)
    if app = apps[match[1]]
      if app.succeed
        session.msg app.last_channel, "Deploy of #{app.name} succeeded \\o/ | PING #{app.last_user}"
        `ssh saunamacmini ./deploy_succeed.sh &`
      end
    else
      not_found
    end
  end

  def rest_fail(request, match)
    if app = apps[match[1]]
      if app.fail
        session.msg app.last_channel, "Deploy of #{app.name} FAILED | PING #{app.last_user}"
        `ssh saunamacmini ./deploy_fail.sh &`
      end
    else
      not_found
    end
  end

  private

  def deploy(app, user, channel)
    status = app.deploy!(user, channel)
    if status =~ /Deploy started/
      session.msg channel, SQUIRRELS.sample
      `ssh saunamacmini ./pre_deploy.sh &`
    end
    session.msg channel, status
  end

  def load_config
    JSON.load(open(File.expand_path(CONFIG_FILE))).symbolize_keys
  end

end
