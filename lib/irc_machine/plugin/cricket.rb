require 'irc_machine'
require 'open-uri'
require 'nokogiri'

class IrcMachine::Plugin::CricketScores < IrcMachine::Plugin::Base
  attr_writer :cricket_feed_url

  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:?.*cricket score/
      session.msg $1, cricket_scores
    end
  end

  def cricket_feed_url
    @cricket_feed_url ||= "http://synd.cricbuzz.com/j2me/1.0/livematches.xml"
  end

  def cricket_scores
    cricket_xml = Nokogiri::XML(open(cricket_feed_url))

    cricket_match = cricket_xml.xpath("//match").first

    cricket_str = [
      sprintf('%s - %s',
        cricket_match['mchDesc'],
        cricket_match.xpath('//state').first['status']
      ),
      sprintf('%s %s/%s',
        cricket_match.xpath('//mscr/btTm').first['sName'],
        cricket_match.xpath('//mscr/btTm/Inngs').first['r'],
        cricket_match.xpath('//mscr/btTm/Inngs').first['wkts'],
      )
    ].join("\n");

    return cricket_str
  end
end
