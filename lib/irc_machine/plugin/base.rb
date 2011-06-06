module IrcMachine
  module Plugin
    class Base
      def initialize(session)
        @session = session
      end
      attr_reader :session
    end
  end
end
