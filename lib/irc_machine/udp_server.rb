module IrcMachine

  class UdpServer < EM::Connection

    attr_writer :session

    def receive_data(data)
      if data =~ /^PRIVMSG (#+\S+) :(.{1,1024})/
        @session.msg $1, $2
      else
        puts "Unrecognized UDP: " << data.inspect
      end
    rescue => e
      puts "!! #{self.class} rescued #{e.inspect}"
      puts "    " + e.backtrace.join("\n    ")
    end

  end

end
