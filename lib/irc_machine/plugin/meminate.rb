require 'meme'

class IrcMachine::Plugin::Meminate < IrcMachine::Plugin::Base
  def initialize
    super
    @meminator = Meme.new
  end

  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG (#+\S+) :meminate$/
      session.msg $1, list_memes.join(" ")
    elsif line =~ /^:\S+ PRIVMSG (#+\S+) :meminate (\S+) (.*)$/
      session.msg $1, fetch_meme($2, $3)
    end
  end

  def list_memes
    @memes ||= GENERATORS.sort.map do |command, (id, name, _)|
      name
    end
  end

  def fetch_meme(name, text)
    return "Unknown meme #{name}" unless list_memes.include?(name)

    begin
      MEME.run "--text", name, text
    rescue Exception => e
      e.message
    end
  end

end
