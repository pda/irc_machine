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

    initialize_jenkins_notifier
    super(*args)
  end

  def recieve_line(line)
    if line =~ build_pattern("rebuild ([^ /])/(\S+)")
      nick, chan, repo, branch = $1, $2, $3, $4

      # Find the most recent build that matches repo and branch
      build_id = @builds.keys.sort{ |a, b| b <=> a }.each do |k|
        build = @builds[k]
        if build.repo_name == repo and build.branch_name == branch
          return trigger_build(build.repo, build.commit)
        end
      end

      session.msg chan, "#{nick}: No builds matching #{bold(repo)}/#{bold(branch)}"

    end
  end

  def create_callback
    lambda { |d| notify d }
  end

  def initialize_jenkins_notifier
    @notifier = ::IrcMachine::Routers::JenkinsRouter.new(@builds) do |endpoint|
      endpoint.on :started do |commit, build|#{{{ Started
        commit.start_time = Time.now.to_i
        # TODO
        notify_privmsg(commit, build, "STARTED")
      end #}}}

      endpoint.on :completed, :success do |commit, build|#{{{ Success
        notify format_msg(commit, build)
        notify_privmsg(commit, build, "SUCCEEDED")
        plugin_send(:JenkinsNotify, :build_success, commit.repo_name, commit.branch,  create_callback)
      end #}}}

      endpoint.on :completed, :failure do |commit, build| #{{{ Failure
        notify format_msg(commit, build)
        notify "Jenkins output available at #{build.full_url}console"
        notify_privmsg(commit, build, "FAILED")
      end #}}}

      endpoint.on :completed, :aborted do |commit, build| #{{{ Aborted
        notify "Build of #{commit.repo_name}/#{commit.branch} ABORTED"
      end #}}}

      endpoint.on :unknown do |build| #{{{ Unknown
        notify "Unknown build of #{build.parameters.SHA1} completed with status #{build.status}"
        notify "Jenkins output available at #{build.full_url}console"
      end #}}}
    end
    route(:post, %r{^/github/jenkins_status$}, @notifier.endpoint)
  end

  def build_branch(request, match)
    commit = ::IrcMachine::Models::GithubNotification.new(request.body.read)

    if project = @projects[commit.repo_name]
      trigger_build(project, commit)
    else
      not_found
    end
  end

  def notify(msg)
    session.msg settings.notify, msg
  end

private

  def trigger_build(project, commit)
    uri = URI(project.builder_url)
    id = next_id
    @builds[id.to_s] = ::IrcMachine::Models::GithubCommit.new({ repo: project, commit: commit, start_time: 0, repo_name: commit.repository.name, branch_name: commit.branch })
    params = defaultParams(project).merge ({SHA1: commit.after, ID: id})

    uri.query = URI.encode_www_form(params)
    return Net::HTTP.get(uri).is_a? Net::HTTPSuccess
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
    session.msg commit.pusher, "Jenkins build of #{commit.repo_name.irc_bold}/#{commit.branch.irc_bold} has #{colorise(status)}: #{build.full_url}console"
  end

  # TODO build model
  def colorise(status)
    case status
    when /^SUCC/
      status.irc_green.irc_bold
    when /^FAIL/
      status.irc_red.irc_bold
    else
      status
    end
  end


  def format_msg(commit, build)
    status = colorise(build.status)
    commit.notification_format(status)
  end

  def build_pattern(text)
    /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? #{text}$/
  end
end
