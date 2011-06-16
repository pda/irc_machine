module IrcMachine
  class IrcConnection < EM::Connection
    include EM::Protocols::LineText2

    attr_writer :session

    def receive_line(line)
      @session.receive_line(line)
    rescue => e
      puts "!! #{self.class} rescued #{e.inspect}"
      puts "    " + e.backtrace.join("\n    ")
    end

    def unbind
      EM.stop
    end

  end
end
