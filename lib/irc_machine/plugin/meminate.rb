require 'meminator'

class IrcMachine::Plugin::Meminate < IrcMachine::Plugin::Base
  CONFIG_FILE = "meminate.json"
  def initialize(*args)
    super(*args)
    @meminator = ::Meminator::Meminator.new

    ::Meminator.username = settings["username"]
    ::Meminator.password = settings["password"]
    route(:get, "/meminate/list", :display_meme_list)
  end

  def receive_line(line)
    if line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? meminate$/
      session.msg $1, "http://#{hostname}:#{session.options.http_port}/meminate/list"
    elsif line =~ /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? meminate (\S+) (.*)$/
      session.msg $1, fetch_meme($2, $3)
    end
  end

  def list_memes
    all_memes.keys.sample(10).map do |key|
      "#{all_memes[key][2]} => #{key}"
    end
  end

  def all_memes
    @all_memes ||= ::Meminator::List.memes
  end

  def fetch_meme(name, text)
    @meminator.get_url(name, *text.split("|"))
  end

  def display_meme_list(request, match)
    memes = all_memes.map do |k, v|
      "#{v[2]}\t\t=>\t#{k}"
    end.join("\r")

    ok memes
  end

  def hostname
    if settings.include? "hostname"
      settings["hostname"]
    else
      "[ThisMachine]"
    end
  end

end
