module IrcMachine
  module Models

    class JuiciNotification

      attr_reader :data

      def initialize(body)
        @data = JSON.parse(body)
      end

      def project
        data["project"]
      end

      def status
        data["status"]
      end

      def url
        data["url"]
      end

    end

  end
end

