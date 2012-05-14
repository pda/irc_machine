require 'meminator'

class IrcMachine::Plugin::Meminate < IrcMachine::Plugin::Base
  CONFIG_FILE = "meminate.json"
  def initialize(*args)
    super(*args)
    @meminator = ::Meminator::Meminator.new
    @config = load_config

    ::Meminator.username = @config.username
    ::Meminator.password = @config.password
    route(:get, "/meminate/list", :display_meme_list)
  end

  def receive_line(line)
    if line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? meminate$/
      list_memes.each do |meme|
        session.msg $1, meme
      end
    elsif line =~ /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? meminate (\S+) (.*)$/
      session.msg $1, fetch_meme($2, $3)
      session.msg $1, "Or get the full list at [ThisMachine]:#{session.options.http_port}/meminate/list"
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

  def load_config
    OpenStruct.new(JSON.load(open(File.expand_path(CONFIG_FILE))))
  end

  def display_meme_list(request, match)
    memes = all_memes.map do |k, v|
      "#{v[2]}\t\t=>\t#{k}"
    end.join("\r")

    ok memes
  end

end
