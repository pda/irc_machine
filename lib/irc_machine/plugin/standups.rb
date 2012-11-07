class IrcMachine::Plugin::Standups < IrcMachine::Plugin::Base
  CONFIG_FILE = "standups.json"

  attr_reader :tasks
  def initialize(*args)
    super(*args)
    @tasks = {}
  end

  def join!
    session.join settings["channel"]
  end

  def receive_line(line)
    if line =~ /^:(\S+)!\S+ PRIVMSG (#\S+) :#{session.state.nick}(?::)? what(?:'s| is) (\S+) (?:up to|working on)\?/
      nick, channel, target = $1, $2, $3
      if target =~ /every(one|body)/
        @tasks.each do |person, data|
          session.msg nick, "#{person} is doing: #{data}"
        end
      else
        if tasks.include? target
          session.msg channel, "#{nick}: #{target} is doing #{tasks[target]}"
        else
          session.msg channel, "#{nick}: I'm not sure what #{target} has planned"
        end
      end
    elsif line =~ /^:(\S+)!\S+ PRIVMSG #{settings["channel"]} :(.*)$/
      puts "tasks[#{$1}] = #{$2}"
      tasks[$1] = "#{$2}, at #{now}"
    end
  end

  def now
    Time.now.strftime("%H:%M %d/%m")
  end
end
