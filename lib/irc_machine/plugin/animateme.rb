require 'json'
require 'net/http'

class IrcMachine::Plugin::AnimateMe < IrcMachine::Plugin::Base

  def initialize(*args)
    super(*args)
    route(:get, %r{^/animate/(.*)$}, :get_animate)
  end

  def get_animate(request, match)
    return redirect(animate_me(match[1]))
  end

  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? (animate|gif)( me)? (.*)$/
      session.msg $1, animate_me($4)
    end
  end

  def animate_me(query)
    uri = URI("http://ajax.googleapis.com/ajax/services/search/images")
    uri.query = URI.encode_www_form({ 'v' => 1.0, 'rsz' => 8, 'safe' => 'active', 'q' => query, 'as_filetype' => 'gif' })

    response = Net::HTTP.get(uri)

    images = JSON.parse(response)['responseData']['results']
    if images.length > 0
      image = images.sample
      "#{image['unescapedUrl']}"
    end
  end
end
