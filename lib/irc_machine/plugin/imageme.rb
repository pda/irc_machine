require 'json'
require 'net/http'

class IrcMachine::Plugin::ImageMe < IrcMachine::Plugin::Base
  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? (image|img)( me)? (.*)$/
      session.msg $1, image_me($4)
    end
  end

  def image_me(query)
    uri = URI("http://ajax.googleapis.com/ajax/services/search/images")
    uri.query = URI.encode_www_form({ 'v' => 1.0, 'rsz' => 8, 'safe' => 'active', 'q' => query })
    response = Net::HTTP.get(uri)

    images = JSON.parse(response).responseData.results
    if images.length > 0
      image = images.sample
      "#{image.unescapedUrl}"
    end
  end

end
