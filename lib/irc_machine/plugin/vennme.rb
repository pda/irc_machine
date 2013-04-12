class IrcMachine::Plugin::VennMe < IrcMachine::Plugin::Base
  VENNME_HOST = "vennme.herokuapp.com"
  def receive_line(line)
    catch(:bad_data) do
      if line =~ /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? (?:venn ?me) (.*)$/
        session.msg $1, venn_me($2)
      end
    end
  end

  def venn_me(string)
    if (match = parse(string))
      uri = URI("http://#{VENNME_HOST}/up")
      uri.query = URI.encode_www_form({
        'a' => 200,
        'b' => 200,
        'ab' => 110,
        'alabel' => match[1].strip,
        'ablabel' => match[2].strip,
        'blabel' => match[3].strip
      })
      uri.to_s + "&fake_param=.jpg"
    else
      throw(:bad_bata)
    end
  end

  def parse(string)
    /^\(([^(]+)\(([^\)]+)\)([^\)]+)\)$/.match(string)
  end
end
