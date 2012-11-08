require 'rest_client'
require 'time'


# Configuration:
#
# The json file should look like:
#
# {
#   "applications": {
#     "NAME_OF_APP": 1234, <- NewRelic App Id
#     "NAME_OF_OTHER_APP": 5678 <- NewRelic App Id
#   },
#   "api_key": "Sekrit",
#   "account_id": 555555, <- NewRelic Account Id
#   "channel": "#performance",
# }

class IrcMachine::Plugin::NewRelicDeployPerformance < IrcMachine::Plugin::Base
  CONFIG_FILE = "newrelic.json"

  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? how is ([^ ]+) performing\??$/
      session.msg $1, report_timing_message($3)
    end
  end

  def deploy_success(app)
    EM.add_timer(400) { report_timing app }
  end

  def pre_deploy(app)
    report_timing app
  end

  def report_timing(app)
    session.msg settings["channel"], report_timing_message(app)
  end

  def report_timing_message(app)
    return "Unknown app '#{app}'; I know about #{settings["applications"].keys.inspect}" unless settings["applications"][app]
    app_id = settings["applications"][app]
    finish = DateTime.now - 240
    start = finish - 60
    score = apdex(:app_id => app_id, :from => start, :to => finish)
    "#{app} apdex 5 minutes ago: #{score}"
  end

  def apdex(options)
    url_params = {
      'metrics[]' => 'EndUser/Apdex',
      'field' => 'score',
      'begin' => options[:from].strftime,
      'end' => options[:to].strftime,
      'summary' => 1
    }
    score = JSON.parse(newrelic_app_data_endpoint(options).get :params => url_params).first["score"]
  end

  def newrelic_app_data_endpoint(options)
    endpoint = "https://api.newrelic.com/api/v1/accounts/#{settings["account_id"]}/applications/#{options[:app_id]}/data.json"
    headers = {"x-api-key" => settings["api_key"]}
    contest_data = RestClient::Resource.new(endpoint, :headers => headers)
  end

end
