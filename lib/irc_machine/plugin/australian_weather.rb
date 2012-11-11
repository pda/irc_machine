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
      session.msg $1, weather_report
    end
  end

  def weather_report
    bom_page = Nokogiri::HTML(RestClient.get(settings["url"]), settings["url"], 'ISO-8859-1')
    forecasts = bom_page.css('.forecast')
    today = forecasts[0]
    tomorrow = forecasts[1]
    max_today = today.at_css('.max').text
    max_tomorrow = tomorrow.at_css('.max').text
    summary_today = today.at_css('.summary').text
    summary_tomorrow = tomorrow.at_css('.summary').text
    <<-FORECAST
Today: #{max_today}, #{summary_today}
Tomorrow: #{max_tomorrow}, #{summary_tomorrow}
    FORECAST
  end

end
