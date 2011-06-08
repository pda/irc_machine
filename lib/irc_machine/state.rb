module IrcMachine
  class State

    attr_accessor :nick
    attr_accessor :channels

    def initialize
      @channels = []
    end

    def channel?(channel)
      channels.include? channel
    end

  end
end
