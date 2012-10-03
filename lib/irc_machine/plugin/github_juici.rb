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

  CONFIG_FILE = "github_juci.json"

  attr_reader :projects

  def initialize(*args)
    super(*args)

    @projects = {}

    route(:post, %r{^/github/juici$}, :build_branch)
  end

  def build_branch(request, match)
    commit = ::IrcMachine::Models::GithubNotification.new(request.body.read)
    if project = get_project[commit.project]

    end
  end

  def get_project(p)
    projects[p] ||= IrcMachine::Models::JuiciProject.new(p, settings["projects"][p]) rescue nil
  end

  def juici_url
    settings["juici_url"]
  end

end
