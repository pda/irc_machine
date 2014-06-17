require 'json'
require 'net/http'
require 'juici/interface'

class IrcMachine::Plugin::JuiciDeploy < IrcMachine::Plugin::Base

  CONFIG_FILE = "github_juici.json"

  extend Callbacks
  has_callbacks "/juici/deploy", :method_name => :new_callback

  def initialize(*args)
    super(*args)

    @disabled_projects = {}
    @project = IrcMachine::Models::JuiciProject.new("deploy", {
      "build_script" => BUILD_SCRIPT
    })
    route(:post, %r{^/juici/deploy$}, :deploy_project)
  end

  def receive_line(line)
    if line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? disable (\S+)$/
      notify "Ok #{$1}, disabling #{$3}"
      set_project_enabled($3, true)
    elsif line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? enable (\S+)$/
      notify "Ok #{$1}, reenabling #{$3}"
      set_project_enabled($3, false)
    elsif line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? (?:deploy|ship) (\S+) (\S+)$/
      user = $1.chomp
      channel = $2.chomp
      project = $3.chomp
      hash = $4.chomp

      ship_project_with_sha(project, hash, user)
    end
  end

  def set_project_enabled(name, enabled)
    project = get_project(name)
    @disabled_projects[project] = enabled
    update_topic
  end

  def get_project(name)
    if name.include? "/"
      name
    else
      "#{settings["default_user"]}/#{name}"
    end
  end

  def update_topic
    if channel = settings["channel"]
      new_topic = "JuiCI | Deploy Status || "
      new_topic << @disabled_projects.map do |project, status|
        "#{project}: #{status ? "disabled" : "shipping"}"
      end.join(" || ")
      session.topic channel, new_topic
    end
  end

  def deploy_project(request, match)
    data = JSON.load(request.body.read)

    project = data["project"] || (raise "No project")
    sha1    = data["sha1"]    || (raise "No sha1")
    authors = data["notify"]

    ship_project_with_sha(project, sha1, authors)
  end

  def ship_project_with_sha(project, sha1, authors)
    if (@disabled_projects[project] == true)
      notify "Not deploying disabled project: #{project} :: PING (#{authors})"
      return
    end

    if channel = settings["channel"]
      plugin_send(:ShipItSquirrels, :send_squirrel, channel)
      notify "Shipping #{project}; reproduce with"
      notify "ship #{project} #{sha1}"
    end

    uri = URI(settings["juici_url"])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"

    plugin_send(:Notifier, :notify, "pre_deploy")

    callback = new_callback do |request, match|
      payload = ::IrcMachine::Models::JuiciNotification.new(request.body.read, :juici_url => settings["juici_url"])
      case payload.status
      when Juici::BuildStatus::FAIL
        plugin_send(:Notifier, :notify, "deploy_failure")
        notify ":warning: deploy for #{project} failed :: PING <!channel> (#{authors})"
      when Juici::BuildStatus::PASS
        plugin_send(:Notifier, :notify, "deploy_success")
        notify ":beers: deploy for #{project} succeeded :: PING (#{authors})"
      end
    end

    payload = @project.build_payload({
      :environment => {
        "REPO" => project,
        "SHA1" => sha1,
        "AUTHOR_NICKS" => authors
      },
      :title => "#{project} :: #{sha1[0..8]}",
      :callbacks => [callback[:url]],
      :priority => 0
    })

    http.start do |h|
      h.post("/builds/new", payload)
    end
  end

  def notify(data)
    if channel = settings["channel"]
      session.msg channel, data
    end
  end

  BUILD_SCRIPT = <<-SCRIPT
#!/bin/sh

if [ ! -d .git ]; then
  git init .
fi

if ! git remote -v | grep "${REPO}"; then

  ssh git@github.com < /dev/null
  if [ "$?" -ne 255 ]; then
    git remote add "${REPO}" "git@github.com:${REPO}.git"
  else
    git remote add "${REPO}" "https://github.com/${REPO}.git"
  fi
fi

set -x
set -e

git fetch -q "${REPO}"

git checkout -fq $SHA1
# Clobber anything from the last project
git clean -xdff

./script/cideploy
SCRIPT

end
