module IrcMachine
  module Models

    class JuiciNotification

      attr_reader :data, :opts

      def initialize(body, opts={})
        @data = JSON.parse(body)
        @opts = opts
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

      def time
        data["time"]
      end

    end

  end
end

