require 'net/http'
class MutexApp
  attr_reader :name, :last_user
  attr_accessor :deploy_url, :auto_deploy

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
    if @deploying
      if @last_state == :disabled
        return "Deploy for #{name} is currently disabled"
      else
        return "Deploy for #{name} in progress by #{last_user}" if @deploying
      end
    end

    @deploying = true
    @last_state = :deploying
    @last_user = user
    @cache[:channel] = channel

    uri = URI(deploy_url)
    Net::HTTP.get(uri)

    return "Deploy started for #{name}"
  end

  def disable!
    @deploying = true
    @last_state = :disabled
  end

  def reset!
    @deploying = false
    @last_state = :initial
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

  def notify(session, msg)
    case last_channel
    when String
      session.msg last_channel, msg
    when Proc
      last_channel.call(msg)
    end
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
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/SHIP_IT.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/ShipIt1.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/ShipIt2.jpg
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/ShipIt3.jpg
  ]


  def initialize(*args)
    @apps = SymbolicHash.new
    load_config.each do |k, v|
      @apps[k] = MutexApp.new(k) do |app|
        app.deploy_url = v[:deploy_url]
        app.auto_deploy = !!v[:auto_deploy]
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

    elsif line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? disable (\S+)$/
      user = $1.chomp
      channel = $2.chomp
      repo = $3.chomp
      app = apps[repo.to_sym]
      if app.nil?
        session.msg channel, "Unknown repo: #{repo}"
      else
        app.disable!
        session.msg channel, "#{repo} has been disabled"
      end
    elsif line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? reset (\S+)$/
      user = $1.chomp
      channel = $2.chomp
      repo = $3.chomp
      app = apps[repo.to_sym]
      if app.nil?
        session.msg channel, "Unknown repo: #{repo}"
      else
        app.reset!
        session.msg channel, "#{repo} has been reset"
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
          session.msg channel, "#{user}: #{repo} is currently #{app.last_state}; caused by #{app.last_user}"
        else
          session.msg channel, "#{user}: #{repo} is not currently being deployed"
        end
      end
    end
  end

  def rest_success(request, match)
    if app = apps[match[1]]
      if app.succeed
        app.notify(session, "Deploy of #{app.name} succeeded \\o/ | PING #{app.last_user}")
        `ssh saunamacmini ./deploy_succeed.sh &`
      end
    else
      not_found
    end
  end

  def rest_fail(request, match)
    if app = apps[match[1]]
      if app.fail
         app.notify(session, "Deploy of #{app.name} FAILED | PING #{app.last_user}")
        `ssh saunamacmini ./deploy_fail.sh &`
      end
    else
      not_found
    end
  end

  # Callback that github_jenkins uses
  def build_success(commit, build, callback)
    repo = commit.repo_name
    branch = commit.branch

    return unless branch == "master"
    return unless (app = @apps[repo])

    if app.auto_deploy
      callback.call("Attempting automatic deploy of #{app.name}")
      callback.call(app.deploy!(commit.pusher, callback))
    end
  end

  def build_fail(commit, build, callback)
    repo = commit.repo_name
    branch = commit.branch

    return unless branch == "master"
    return unless (app = @apps[repo])

    callback.call("Disabling deploys due to failed build of #{app.name}")
    app.disable!
    callback.call("#{app.name} has been disabled")
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
