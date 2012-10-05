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
#   "juici_url" : "http://juici.herokuapp.com"
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
    uri = URI(juici_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"

    callback_url = new_callback_url
    route(:post, callback_url,
      status_callback(:project => project, :commit => commit, :opts => opts))

    http.start do |h|
      response = h.post("/builds/new", project.build_payload(:environment => opts[:environment], :callbacks => [callback_url]))
    end
  end

  def get_project(p)
    projects[p] ||= IrcMachine::Models::JuiciProject.new(p, projects[p])
  end

  def juici_url
    settings["juici_url"]
  end

  def projects
    settings["projects"] || {}
  end

  def notify(data)
    if channel = settings["channel"]
      session.msg channel, data
    end
  end

  def new_callback_url
    "/juici/status/#{@uuid.generate}"
  end

  def status_callback(data={})
    started = Time.now.to_i
    project = data[:project]
    commit = data[:commit]
    opts = data[:opts]

    def time_elapsed
      Time.now.to_i - started
    end

    lambda { |request, match|
      # TODO Include some logic for working out if we're done with this route
      # and calling #drop_route!
      payload = ::IrcMachine::Models::JuiciNotification.new(request.body.read)
      notify "#{payload.status} - #{project.name} built in #{time_elapsed}s :: JuiCI #{payload.url}"
    }
  end
end
