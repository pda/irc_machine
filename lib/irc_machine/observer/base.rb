module IrcMachine
  module Observer
    class Base
      def initialize(session)
        @session = session
      end
      attr_reader :session
    end
  end
end
