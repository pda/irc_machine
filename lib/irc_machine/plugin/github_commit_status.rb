require 'json'
require 'net/http'
class IrcMachine::Plugin::GithubCommitStatus < IrcMachine::Plugin::Base

  CONFIG_FILE = "github_commit_status.json"
  VALID_STATUSES = %w[pending success error failure]

  def mark(project, sha, status, opts={})
    raise InvalidStatus unless VALID_STATUSES.include? status
    json = opts.merge({"state" => status})
    post(url_for(project, sha), json)
  end

  def endpoint
    @endpoint = settings["endpoint"] || "https://api.github.com"
  end

  def url_for(project, sha)
    "#{endpoint}/repos/#{project}/statuses/#{sha}"
  end

private

  def post(url, data=nil)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"

    http.start do |h|
      response = h.post(uri.request_uri, data.to_json)
    end
  end

  def request_headers
    {
      "Authorization"=> "token #{settings["token"]}"
    }
  end

  class InvalidStatus < Exception
  end

end
