module IrcMachine
  class State

    attr_accessor :nick
    attr_accessor :channels

    def initialize
      reset
    end

    def reset
      @nick = nil
      @channels = []
    end

    def channel?(channel)
      channels.include? channel
    end

  end
end
