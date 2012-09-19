require "json"
require "cgi"
require "ostruct"

module IrcMachine
  module Models

    class JenkinsNotification

      attr_reader :data

      def initialize(body)
        @data = OpenStruct.new(JSON.parse(body))
      end

      def repo_name
        data.name
      end

      def url
        data.url
      end

      def full_url
        data.build["full_url"]
      end

      def status
        data.build["status"]
      end

      def phase
        data.build["phase"]
      end

      def parameters
        @parameters ||= OpenStruct.new(data.build["parameters"])
      end

    end

  end
end
