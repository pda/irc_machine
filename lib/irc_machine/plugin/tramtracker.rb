require 'irc_machine'
require 'rest_client'
require 'nokogiri'

# Configuration:
#
# The json file should look like:
#
# { "stops": {
#     "Outbound": "2716",
#     "Citybound": "1716"
#   },
#   "url_pattern": "http://tramtracker.com.au/?id=STOP_ID"
# }
#

class IrcMachine::Plugin::TramTracker < IrcMachine::Plugin::Base
  CONFIG_FILE = "trams.json"

  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? when is the next tram\??$/
      departure_times.each { |message| session.msg $1, message }
    end
  end

  def departure_times
    info = []
    settings["stops"].each do |description, id|
      url = settings["url_pattern"].gsub(/STOP_ID/, id)
      # This is basically the worst HTML ever, so the scraping is a little primitive.
      tracker_page = Nokogiri::HTML(RestClient.get(url)).text.lines.to_a.map &:strip

      id_line = "ID: #{id}"
      if not tracker_page.index(id_line)
        info << "Error parsing tramtracker page for #{description}"
        info << "Could not find #{id_line.inspect} in:\n #{tracker_page.join("\n")}"
      else
        start = tracker_page.index(id_line) + 1
        finish = start + 5
        tracker_page[(start..finish)].each_slice(2) do |route, time|
          route = route.gsub(/.\) Rte /, ' ').strip
          time = time.gsub(/\*/, '').strip
          info << "#{description}: #{route} in #{time}"
        end
      end
    end
    info
  end


end
