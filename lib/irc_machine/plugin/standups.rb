class IrcMachine::Plugin::Standups < IrcMachine::Plugin::Base
  CONFIG_FILE = "standups.json"

  attr_reader :config, :tasks
  def initialize(*args)
    super(*args)
    @config = load_config
    @tasks = {}
  end

  def join!
    session.join config.channel
  end

  def receive_line(line)
    if line =~ /^:(\S+)!\S+ PRIVMSG #{config.channel} :(.*)$/
      tasks[$1] = $2
    elsif line =~ /^:(\S+)!\S+ PRIVMSG (#\S+) :what(?:'s| is) (\S+) (?:up to|working on)\?/
      nick, channel, target = $1, $2, $3
      if target =~ /every(one|body)/
        @tasks.each do |person, data|
          session.msg nick, "#{person} is doing: #{data}"
        end
      else
        session.msg channel, "#{nick}: person is doing #{data}"
      end
    end
  end

  # TODO move to base?
  def load_config
    OpenStruct.new(JSON.load(open(File.expand_path(CONFIG_FILE))))
  end
end
