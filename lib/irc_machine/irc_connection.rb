module IrcMachine
  class IrcConnection < EM::Connection
    include EM::Protocols::LineText2

    attr_writer :session

    def receive_line(line)
      @session.receive_line(line)
    end

    def unbind
      EM.stop
    end

  end
end
