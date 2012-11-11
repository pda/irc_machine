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
    bom_page = Nokogiri::HTML(RestClient.get(settings["url"]))
    forecasts = bom_page.css('.forecast')
    today = forecasts[0]
    tomorrow = forecasts[1]
    <<-FORECAST
Today: #{today.at_css('.max').text}, #{today.at_css('.summary').text}
Tomorrow: #{tomorrow.at_css('.max').text}, #{tomorrow.at_css('.summary').text}
    FORECAST
  end

end
