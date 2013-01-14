require 'irc_machine'
require 'rest_client'
require 'nokogiri'

# Configuration:
#
# The json file should look like:
#
# { "url": "http://www.bom.gov.au/vic/forecasts/melbourne.shtml" }
#

class IrcMachine::Plugin::AustralianWeather < IrcMachine::Plugin::Base
  CONFIG_FILE = "weather.json"

  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? how is the weather\??$/
      weather_report.each {|message| session.msg $1, message }
    end
  end

  def weather_report
    bom_page = Nokogiri::HTML(RestClient.get(settings["url"]), settings["url"], 'ISO-8859-1')
    forecasts = bom_page.css('.forecast')
    today = forecasts[0]
    tomorrow = forecasts[1]

    max_today = today.at_css('.max').text rescue "No temp. specified"
    max_tomorrow = tomorrow.at_css('.max').text rescue "No summary"
    summary_today = today.at_css('.summary').text rescue "No temp. specified"
    summary_tomorrow = tomorrow.at_css('.summary').text rescue "No summary"
    [
      "Today: #{max_today}, #{summary_today}",
      "Tomorrow: #{max_tomorrow}, #{summary_tomorrow}"
    ]
  end

end
