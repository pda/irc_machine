module IrcMachine
  module Models

    class JuiciNotification

      attr_reader :data

      def initialize(body, opts={})
        @data = JSON.parse(body)
      end

      def project
        data["project"]
      end

      def status
        data["status"]
      end

      def url
        "#{opts[:juici_url]}#{data["url"]}"
      end

    end

  end
end

