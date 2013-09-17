require 'json'
require 'net/http'
require 'juici/interface'

class IrcMachine::Plugin::JuiciDownstream < IrcMachine::Plugin::Base

  CONFIG_FILE = "github_juici.json"

  extend Callbacks
  has_callbacks "/juici/build_project", :method_name => :new_callback

  def initialize(*args)
    super(*args)

    route(:post, %r{^/juici/build_project$}, :build_project)
  end

  def build_project(request, match)
    data = JSON.load(request.body.read)

    project = data["project"]  || (raise "No project")
    sha1    = data["sha1"]     || "master"
    script  = data["script"]   || "./script/cibuild"
    from    = data["upstream"] || (raise "Upstream project required")

    uri = URI(settings["juici_url"])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"

    callback = new_callback do |request, match|
      payload = ::IrcMachine::Models::JuiciNotification.new(request.body.read, :juici_url => settings["juici_url"])
      case payload.status
      when Juici::BuildStatus::FAIL
        notify "[Fail] Build of #{project}/#{sha1} failed (triggered by #{from})"
      when Juici::BuildStatus::PASS
        notify "[Success] Build of #{project}/#{sha1} passed (triggered by #{from})"
      end
    end

    @project = IrcMachine::Models::JuiciProject.new(project, {
      "build_script" => build_script(project, script)
    })
    payload = @project.build_payload({
      :environment => {
        "SHA1" => data["sha1"]
      },
      :title => "#{data["project"]} :: #{sha1[0..8]}",
      :callbacks => [callback[:url]]
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

  def build_script(repo, script)
    <<-SCRIPT
      #!/bin/sh

      if [ ! -d .git ]; then
        git init .
        git remote add origin git@github.com:#{repo}.git
      fi

      git fetch origin
      git checkout -fq $SHA1
      # Clobber anything from the last build
      git clean -xdff
      #{script}
    SCRIPT
  end
end
