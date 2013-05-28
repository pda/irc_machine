class IrcMachine::Plugin::JuiciDeploy < IrcMachine::Plugin::Base

  CONFIG_FILE = "github_juici.json"

  def initialize(*args)
    super(*args)

    @uuid = UUID.new
    @disabled_projects = {}
    @project = IrcMachine::Models::JuiciProject.new("deploy", {
      "build_script" => BUILD_SCRIPT
    })
    route(:post, %r{^/juici/deploy$}, :deploy_project)
  end

  def deploy_project(request, match)
    data = JSON.load(request.body.read)

    project = data["project"] || (raise "No project")
    sha1    = data["sha1"]    || (raise "No sha1")

    if (@disabled_projects[project] == true)
      notify "Not deploying disabled project: #{project}"
      return
    end

    uri = URI(settings["juici_url"])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"

    callback = new_callback
    route(:post, callback[:path], lambda { |request, match|
      payload = ::IrcMachine::Models::JuiciNotification.new(request.body.read, :juici_url => juici_url)
      case payload.status
      when Juici::BuildStatus::FAIL
        notify "D: deploy for #{project} failed"
      when Juici::BuildStatus::PASS
        notify "\\o/ deploy for #{project} succeeded"
      end

    })

    payload = @project.build_payload({
      :environment => {
        "REPO" => data["project"],
        "SHA1" => data["sha1"]
      },
      :title => "#{data["project"]} :: #{data["sha1"][0..8]}",
      :callbacks => [callback[:url]],
      :priority => 0
    })

    http.start do |h|
      h.post("/builds/new", payload)
    end
  end

  def new_callback
    callback = {}
    callback[:url] = URI(settings["callback_base"]).tap do |uri|
      callback[:path] = "/juici/deploy/#{@uuid.generate}"
      uri.path = callback[:path]
    end
    callback
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

git fetch -q "${REPO}"

git checkout -fq $SHA1
# Clobber anything from the last project
git clean -xdff

./script/cideploy
SCRIPT

end
