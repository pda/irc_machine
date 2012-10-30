require 'json'
require 'net/http'
require 'uuid'

# TODO potentially merge this with the jenkins plugin?
#
# Configuration:
#
# The json file should look like:
#
# Projects, and indeed the entire projects stanza is optional. If none are
# given, any projects you point to agent99 will inherit some sane(ish)
# defaults.
#
# {
#   "projects" : {
#     "user/repo" : {
#       "build_script": "
# exit 0
# "
#     },
#   "channel" : "#juici",
#   "juici_url" : "http://juici.herokuapp.com",
#   "callback_base" : "http://agent99.example.com"
# }

class IrcMachine::Plugin::GithubJuici < IrcMachine::Plugin::Base

  CONFIG_FILE = "github_juici.json"

  attr_reader :projects

  def initialize(*args)
    super(*args)

    @projects = {}
    @uuid = UUID.new

    route(:post, %r{^/github/juici$}, :build_branch)
  end

  def build_branch(request, match)
    commit = ::IrcMachine::Models::GithubNotification.new(request.body.read)
    if project = get_project(commit.project)
      start_build(project, commit, :environment => {"SHA1" => commit.after, "ref" => commit.ref})
    end
  end

  def start_build(project, commit, opts={})
    priority = project.priorities[commit.branch]
    uri = URI(juici_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"

    callback = new_callback
    route(:post, callback[:path],
      status_callback(:project => project, :commit => commit, :opts => opts))

    http.start do |h|
      response = h.post("/builds/new", project.build_payload(:environment => opts[:environment], :callbacks => [callback[:url]], :title => commit.branch, :priority => priority))
    end
  end

  def get_project(p)
    projects[p] ||= IrcMachine::Models::JuiciProject.new(p, project_settings[p])
  end

  def juici_url
    settings["juici_url"]
  end

  def project_settings
    settings["projects"] || {}
  end

  def notify(data)
    if channel = settings["channel"]
      session.msg channel, data
    end
  end

  def new_callback
    callback = {}
    callback[:url] = URI(settings["callback_base"]).tap do |uri|
      callback[:path] = "/juici/status/#{@uuid.generate}"
      uri.path = callback[:path]
    end
    callback
  end

  def status_callback(data={})
    started = Time.now.to_i
    project = data[:project]
    commit = data[:commit]
    opts = data[:opts]

    time_elapsed = lambda { Time.now.to_i - started }

    lambda { |request, match|
      # TODO Include some logic for working out if we're done with this route
      # and calling #drop_route!
      payload = ::IrcMachine::Models::JuiciNotification.new(request.body.read, :juici_url => juici_url)
      notify "#{payload.status} - #{project.name} :: #{commit.branch} :: built in #{time_elapsed.call}s :: JuiCI #{payload.url} :: PING #{commit.author_nicks.join(" ")}"
      mark_build(commit, payload.status)

      notify_callback = lambda { |str| notify str }
      case payload.status
      when "failed"
        plugin_send(:JenkinsNotify, :build_fail, commit, nil,  notify_callback)
      when "success"
        plugin_send(:JenkinsNotify, :build_success, commit, nil, notify_callback)
      end
    }
  end

  def mark_build(commit, status)
    project = "#{commit.repository.owner["name"]}/#{commit.repo_name}"
    sha     = commit.after
    status = case status
             when "failed"
               "failure"
             else
               status
             end
    plugin_send(:GithubCommitStatus, :mark, project, sha, status)
  end
end
