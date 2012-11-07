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
    if @deploying
      if @last_state == :disabled
        return "#{"DEPLOY".irc_cyan.irc_bold} - #{name} is currently disabled because #{reason}"
      else
        return "#{"DEPLOY".irc_cyan.irc_bold} - #{name} in progress by #{last_user}" if @deploying
      end
    end

    @deploying = true
    @last_state = :deploying
    @last_user = user
    @cache[:channel] = channel

    uri = URI(deploy_url)
    Net::HTTP.get(uri)

    return "#{"DEPLOY".irc_cyan.irc_bold} - started for #{name}"
  end

  def disable!(opts = {})
    @deploying = true
    @last_state = :disabled
    @reason = opts[:reason]
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

  def reason
    @reason || "of reasons"
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
    http://99designs-shipit-squirrels.s3-website-us-east-1.amazonaws.com/shipitship.jpg
  ]


  def initialize(*args)
    super(*args)
    @apps = Hash.new
    settings.each do |k, v|
      @apps[k] = MutexApp.new(k) do |app|
        app.deploy_url = v["deploy_url"]
        app.auto_deploy = v["auto_deploy"] || false
      end

      route(:get, %r{/deploy/(#{k})/success}, :rest_success)
      route(:get, %r{/deploy/(#{k})/fail}, :rest_fail)
      route(:post, %r{/deploy/(#{k})/notice}, :rest_notice)

    end

  end
  attr_reader :apps

  def receive_line(line)
    # TODO Regex
    if line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? (?:deploy|ship) (\S+)$/
      user = $1.chomp
      channel = $2.chomp
      repo = $3.chomp

      app = apps[repo]
      if app.nil?
        session.msg channel, "Unknown repo: #{repo}"
      else
        deploy(app, user, channel)
      end

    elsif line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? disable (\S+)( .*)?$/
      user = $1.chomp
      channel = $2.chomp
      repo = $3.chomp
      reason = $4.chomp rescue nil
      app = apps[repo]
      if app.nil?
        session.msg channel, "Unknown repo: #{repo}"
      else
        app.disable!(:reason => reason)
        session.msg channel, "#{repo} has been disabled because #{app.reason}"
      end
    elsif line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? reset (\S+)$/
      user = $1.chomp
      channel = $2.chomp
      repo = $3.chomp
      app = apps[repo]
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

      app = apps[repo]
      if app.nil?
        session.msg channel, "Unknown repo: #{repo}"
      else
        if app.deploying?
          session.msg channel, "#{user}: #{repo.irc_bold} is currently #{app.last_state}; caused by #{app.last_user} because #{app.reason}"
        else
          session.msg channel, "#{user}: #{repo.irc_bold} is not currently being deployed"
        end
      end
    end
  end

  def rest_success(request, match)
    if app = apps[match[1]]
      if app.succeed
        app.notify(session, "#{"DEPLOY".irc_cyan.irc_bold} - #{app.name.to_s.irc_bold} succeeded \\o/ | PING #{app.last_user}")
        plugin_send(:Notifier, :notify, "deploy_success")
        plugin_send(:NewRelicDeployPerformance, :deploy_success, app.name)
      end
    else
      not_found
    end
  end

  def rest_fail(request, match)
    if app = apps[match[1]]
      if app.fail
         app.notify(session, "#{"DEPLOY".irc_cyan.irc_bold} - #{app.name.to_s.irc_bold} FAILED | PING #{app.last_user}")
         plugin_send(:Notifier, :notify, "deploy_failure")
      end
    else
      not_found
    end
  end

  def rest_notice(request, match)
    if app = apps[match[1]]
      app.notify(session, request.body.read)
    end
  end

  # Callback that github_jenkins uses
  def build_success(commit, build, callback)
    repo = commit.repo_name
    branch = commit.branch

    return unless (app = @apps[repo])
    return unless branch == app.auto_deploy

    callback.call("#{"DEPLOY".irc_cyan.irc_bold} - Attempting automatic deploy of #{app.name}")
    callback.call(app.deploy!(commit.pusher, callback).tap do |status|
      if status =~ /started for/
        callback.call(SQUIRRELS.sample)
        plugin_send(:Notifier, :notify, "pre_deploy")
        plugin_send(:NewRelicDeployPerformance, :pre_deploy, app.name)
      end
    end)
  end

  def build_fail(commit, build, callback)
    repo = commit.repo_name
    branch = commit.branch

    return unless (app = @apps[repo])
    return unless branch == (app.auto_deploy || "master")

    callback.call("#{"DEPLOY".irc_cyan.irc_bold} - Disabling deploys due to failed build of #{app.name}")
    app.disable!(:reason => "commit #{commit.after} by #{commit.pusher}")
    callback.call("#{app.name} has been disabled")
  end


  private

  def deploy(app, user, channel)
    status = app.deploy!(user, channel)
    if status =~ /started for/
      session.msg channel, SQUIRRELS.sample
      plugin_send(:Notifier, :notify, "pre_deploy")
    end
    session.msg channel, status
  end

end
