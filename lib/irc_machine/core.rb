module IrcMachine
  class Core < Plugin::Base

    def connected
      session.password options.password unless options.password.nil?
      session.user options.user, options.realname
      session.nick options.nick
      session.state.nick = options.nick
      EM::add_timer(5) do
        if options.prelude
          options.prelude.each do |line|
            session.raw line
          end
          EM::add_timer(10) do
            join_channels
          end
        else
          join_channels
        end
      end
    end

    def terminate
      session.quit "shutting down"
    end

    def receive_line(line)

      puts "[core] << #{line}" if options.verbose

      case line

      when /^PING (.*)/
        session.raw "PONG #{$1}"

      when /^:#{self_pattern} JOIN :(\S+)/
        channels << $1

      when /^:#{self_pattern} PART :(\S+)/
        channels.delete $1

      when /^:\S+ 475 \S+ (\S+) :(.*)$/
        puts "[core] #{$1}: #{$2}"

      end
    end

    private

    def options
      session.options
    end

    def self_pattern
      Regexp.escape(session.state.nick) + '!\S+@\S+'
    end

    def channels
      session.state.channels
    end

    def join_channels
      options.channels.each { |c| session.join *c.split } if options.channels
    end
  end
end
