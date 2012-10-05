require 'net/http'

# TODO potentially merge this with the jenkins plugin?
#
# Configuration:
#
# The json file should look like:
#
# {
#   "projects" : {
#     "user/repo" : {
#

class IrcMachine::Plugin::GithubJuici < IrcMachine::Plugin::Base

  CONFIG_FILE = "github_juici.json"

  attr_reader :projects

  def initialize(*args)
    super(*args)

    @projects = {}

    route(:post, %r{^/github/juici$}, :build_branch)
  end

  def build_branch(request, match)
    commit = ::IrcMachine::Models::GithubNotification.new(request.body.read)
    if project = get_project(commit.project)
      start_build(project, commit, :environment => {"SHA1" => commit.after})
    end
  end

  def start_build(project, commit, opts={})
    uri = URI(juici_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"

    http.start do |h|
      response = h.post("/builds/new", project.build_payload(:environment => opts[:environment]))
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
end
