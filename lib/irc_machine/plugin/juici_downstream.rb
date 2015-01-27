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
    sha1    = data["sha1"]     || "origin/master"
    title   = data["title"]    || "#{project}/#{sha1[0..8]}"
    script  = data["script"]   || "./script/cibuild"
    authors = data["notify"]
    from    = data["upstream"] || (raise "Upstream project required")

    uri = URI(settings["juici_url"])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"

    callback = new_callback do |request, match|
      payload = ::IrcMachine::Models::JuiciNotification.new(request.body.read, :juici_url => settings["juici_url"])
      ping = ""
      ping = " :: PING #{authors}" if authors.strip != "" && authors != "@channel"
      case payload.status
      when Juici::BuildStatus::FAIL
        notify ":x: Build of #{title} failed (triggered by #{from}) :: #{payload.url}#{ping} <!channel>"
      when Juici::BuildStatus::PASS
        notify ":white_check_mark: Build of #{title} passed (triggered by #{from}) :: #{payload.url}#{ping}"
      end
    end

    @project = IrcMachine::Models::JuiciProject.new(project, {
      "build_script" => build_script(project, script)
    })
    payload = @project.build_payload({
      :environment => {
        "AWS_ACCESS_KEY_ID" => settings["aws"]["key"],
        "AWS_SECRET_ACCESS_KEY" => settings["aws"]["secret"],
        "SHA1" => data["sha1"],
        "AUTHOR_NICKS" => authors
      },
      :title => title,
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
      if [ -n "$SHA1" ]; then
        git checkout -fq $SHA1
      else
        git checkout -fq origin/master
      fi
      # Clobber anything from the last build
      git clean -xdff
      #{script}
    SCRIPT
  end
end
