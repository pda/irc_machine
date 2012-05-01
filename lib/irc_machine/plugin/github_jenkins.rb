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
# TODO Cleanup this commit.commit bollox
class IrcMachine::Plugin::GithubJenkins < IrcMachine::Plugin::Base

  CONFIG_FILE = "github_jenkins.json"

  attr_reader :settings
  def initialize(*args)
    @repos = Hash.new
    @builds = Hash.new
    conf = load_config

    conf["builds"].each do |k, v|
      @repos[k] = OpenStruct.new(v)
    end

    @settings = OpenStruct.new(conf["settings"])
    @usernames = conf["usernames"] || {}

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

    if repo = @repos[commit.repo_name]
      trigger_build(repo, commit)
    else
      not_found
    end
  end

  def notify(msg)
    session.msg settings.notify, msg
  end

private

  def get_nick(author)
    @usernames[author] || author
  end

  def trigger_build(repo, commit)
    uri = URI(repo.builder_url)
    id = next_id
    @builds[id.to_s] = OpenStruct.new({ repo: repo, commit: commit, start_time: 0, repo_name: commit.repository.name, branch_name: commit.branch })
    params = defaultParams(repo).merge ({SHA1: commit.after, ID: id})

    uri.query = URI.encode_www_form(params)
    return Net::HTTP.get(uri).is_a? Net::HTTPSuccess
  end

  def load_config
    JSON.load(open(File.expand_path(CONFIG_FILE)))
  end

  def next_id
    Time.now.to_i
  end

  def defaultParams(repo)
    { token: repo.token }
  end

  def bold(txt)
    "#{0x02.chr}#{txt}#{0x0F.chr}"
  end

  def color(txt, colorcode)
    "#{0x03.chr}#{colorcode}#{txt}#{0x03.chr}"
  end

  def green(txt)
    color(txt, 3)
  end

  def red(txt)
    color(txt, 4)
  end

  def notify_privmsg(commit, build, status)
    commit = commit.commit
    pusher = get_nick(commit.commits.last["author"]["username"])
    session.msg pusher, "Jenkins build of #{bold(commit.repo_name)}/#{bold(commit.branch)} has #{bold(status)}: #{build.full_url}console"
  end

  def format_msg(commit, build)
     build_time = Time.now.to_i - commit.start_time
     commit = commit.commit
     authors = commit.author_usernames.map { |a| get_nick(a) }
     status = case build.status
              when "SUCCESS"
                bold(green(build.status))
              when "FAILURE"
                bold(red(build.status))
              else
                build.status
              end

    "Build of #{bold(commit.repo_name)}/#{bold(commit.branch)} was a #{status} #{commit.repository.url}/compare/#{commit.before[0..6]}...#{commit.after[0..6]} in #{bold(build_time)}s PING #{authors.join(" ")}"
  end

  def build_pattern(text)
    /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? #{text}$/
  end
end
