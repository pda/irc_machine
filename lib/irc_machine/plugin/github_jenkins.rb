require 'net/http'
# * Configuration
# Project needs to be configured in jenkins with two parameters:
# - SHA1 : Takes a sha hash to build
# - ID   : Takes unique ID, purely for passing back to work out which build it
#          was that we're looking at
#
# Then configuration in the .json file is
# - {
#     "settings": {
#       "notify": "#builds"
#     },
#     "usernames": {
#       "richoH": "richo"
#     },
#     "builds": {
#       "reponame": {
#         "builder_url": "URL GOES HERE",
#         "token"      : "JENKINS_TOKEN",
#       }
#     }
#   }
#
# usernames is an optional hash of github -> irc nickname mappings so that users can be usefully notified
#
class IrcMachine::Plugin::GithubJenkins < IrcMachine::Plugin::Base

  CONFIG_FILE = "github_jenkins.json"

  attr_reader :settings
  def initialize(*args)
    @projects = Hash.new
    @commits = Hash.new
    @builds = Hash.new
    conf = load_config

    conf["builds"].each do |k, v|
      @projects[k] = OpenStruct.new(v)
    end

    @settings = OpenStruct.new(conf["settings"])

    # {}Seed the cache of usernames
    if conf.include? "usernames"
      ::IrcMachine::Models::GithubUser.nicks = conf["usernames"]
    end

    route(:post, %r{^/github/jenkins$}, :build_branch)
    route(:post, %r{^/github/jenkins_status$}, :jenkins_status)
    route(:post, %r{^/github/notice$}, :rest_notice)
    route(:get, %r{^/status/all$}, :all_builds_status)
    route(:get, %r{^/status/([a-f0-9]+)$}, :build_status)

    initialize_jenkins_notifier
    super(*args)
  end

  def receive_line(line)
    if line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? build (\S+)$/
      nick, chan, buildspec = $1, $2, $3
      repo, ref = buildspec.split(?/, 2)
      if project = @projects[repo]
        if ref.length < 7
          session.msg chan, "#{nick}: at least 7 chars of the ref are required"
        else
          trigger_adhoc_build(project, ref, :nick => nick, :repo => repo, :chan => chan)
        end
      else
        session.msg chan, "#{nick}: No projects matching #{repo}"
      end
    elsif line =~ build_pattern("rebuild ([^ /])/(\S+)")
      nick, chan, repo, branch = $1, $2, $3, $4

      # Find the most recent build that matches repo and branch
      build_id = @commits.keys.sort{ |a, b| b <=> a }.each do |k|
        build = @commits[k]
        if build.repo_name == repo and build.branch_name == branch
          return trigger_build(build.repo, build.commit)
        end
      end

      session.msg chan, "#{nick}: No builds matching #{bold(repo)}/#{bold(branch)}"

    end
  end

  def rest_notice(request, match)
    notify request.body.read
  end

  def jenkins_status(request, match)
    @notifier.process(request.body.read) do |build|
      p = build.parameters
      @builds[p.SHA1] = build
    end
  end

  def all_builds_status(request, match)
    ok (@builds.map {|k, v| "#{k} => #{v.status}" }.join("\r\n"))
  end

  def build_status(request, match)
    if @builds.include?(match[1])
      ok @builds[match[1]].status
    else
      ok "UNKNOWN"
    end
  end

  def create_callback
    lambda { |d| notify d }
  end

  def initialize_jenkins_notifier
    @notifier = ::IrcMachine::Routers::JenkinsRouter.new(@commits) do |endpoint|
      endpoint.on :started do |commit, build|#{{{ Started
        commit.start_time = Time.now.to_i
        # TODO
        notify_privmsg(commit, build, "STARTED")
      end #}}}

      endpoint.on :completed, :success do |commit, build|#{{{ Success
        notify build_complete_message(commit, build)
        notify_privmsg(commit, build, "SUCCEEDED")
        plugin_send(:JenkinsNotify, :build_success, commit, build, create_callback)
      end #}}}

      endpoint.on :completed, :failure do |commit, build| #{{{ Failure
        notify build_complete_message(commit, build)
        notify_privmsg(commit, build, "FAILED")
        plugin_send(:JenkinsNotify, :build_fail, commit, build,  create_callback)
      end #}}}

      endpoint.on :completed, :aborted do |commit, build| #{{{ Aborted
        notify "Build of #{commit.repo_name}/#{commit.branch} ABORTED"
      end #}}}

      endpoint.on :unknown do |build| #{{{ Unknown
        notify "Unknown build of #{build.parameters.SHA1} completed with status #{build.status}"
        notify "Jenkins output available at #{build.full_url}console"
      end #}}}
    end
  end

  def build_complete_message(commit, build)
    github_prefix = commit.repository.url || "";

    if commit.tag?
      github = "#{github_prefix}/tree/#{commit.branch}"
    else
      github = "#{github_prefix}/compare/#{commit.before[0..6]}...#{commit.after[0..6]}"
    end

    # SUCCESS - contests/master built in 133s :: PHP 1234 :: JS 5678 :: diff http://git.io/abc123 :: PING bradfeehan
    # FAILURE - contests/master built in 432s :: PHP 2345 :: JS 6789 :: diff http://git.io/def456 :: Jenkins http://jenkins.99cluster.com/job/contests/6543/console :: PING bradfeehan
    if build.status =~ /^SUCC/
      "#{colorise(build.status)} - #{commit.repo_name.irc_bold}/#{commit.branch.irc_bold} built in #{commit.build_time.irc_bold}s :: #{github} :: PING #{commit.users_to_notify.join(" ")}"
    else
      "#{colorise(build.status)} - #{commit.repo_name.irc_bold}/#{commit.branch.irc_bold} built in #{commit.build_time.irc_bold}s :: #{github} :: Jenkins #{build.full_url} :: PING #{commit.users_to_notify.join(" ")}"
    end
  end

  def build_branch(request, match)
    commit = ::IrcMachine::Models::GithubNotification.new(request.body.read)

    if project = @projects[commit.repo_name]
      if commit.after == "0000000000000000000000000000000000000000"
        notify "Not building deleted branch #{commit.repo_name}/#{commit.branch}"
      else
        trigger_build(project, commit)
      end
    else
      not_found
    end
  end

  def notify(msg)
    session.msg settings.notify, msg
  end

private

  def trigger_adhoc_build(project, ref, opts={})
    commit = OpenStruct.new({
      :repository => OpenStruct.new({ :name => opts[:repo] }),
      :repo_name => opts[:repo],
      :branch => ref,
      :before => "[adhoc]",
      :after  => ref,
      :commits => [{"author" => OpenStruct.new({ :nick => opts[:nick] })}],
      # Hax to ensure the requester is notified
      :authors => [OpenStruct.new({ :nick => opts[:nick] })],
    })
    if trigger_build(project, commit) && opts[:chan]
      session.msg opts[:chan], "Build of #{opts[:repo]}/#{ref} successfully queued"
    end
  end

  def trigger_build(project, commit)
    uri = URI(project.builder_url)
    id = next_id
    @commits[id.to_s] = ::IrcMachine::Models::GithubCommit.new({ repo: project, commit: commit, start_time: 0, repo_name: commit.repository.name, branch_name: commit.branch })
    params = defaultParams(project).merge ({SHA1: commit.after, ID: id})

    uri.query = URI.encode_www_form(params)
    case Net::HTTP.get_response(uri)
    when Net::HTTPSuccess
      return true
    when Net::HTTPFound
      return true
    else
      return false
    end
  end

  def load_config
    JSON.load(open(File.expand_path(CONFIG_FILE)))
  end

  def next_id
    Time.now.to_i
  end

  def defaultParams(project)
    { token: project.token }
  end

  def notify_privmsg(commit, build, status)
    pusher = commit.pusher
    unless pusher.nil?
      session.msg commit.pusher, "Jenkins build of #{commit.repo_name.irc_bold}/#{commit.branch.irc_bold} has #{colorise(status)}: #{build.full_url}console"
    end
  end

  # TODO build model
  def colorise(status)
    case status
    when /^SUCC/
      status.irc_green.irc_bold
    when /^FAIL/
      status.irc_red.irc_bold
    when /^STAR/
      status.irc_yellow.irc_bold
    else
      status
    end
  end

  def build_pattern(text)
    /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? #{text}$/
  end
end
