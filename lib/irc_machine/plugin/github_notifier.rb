require "json"
require "cgi"
require "ostruct"

module IrcMachine
  module Plugin

    class GithubNotifier < Plugin::Base
    end

    class GithubNotification

      attr_reader :data

      def initialize(body)
        json = CGI.parse(body)["payload"][0]
        @data = OpenStruct.new(JSON.parse(json))
      end

      def repo_name
        data.repository["name"]
      end

      def commit_count
        data.commits.size
      end

      def branch
        data.ref.gsub(%r{refs/heads/}, "")
      end

      def authors
        data.commits.map{ |c| OpenStruct.new c["author"] }
      end

      def author_usernames
        authors.map{ |a| a.username }.uniq
      end

      def compare_url
        data.compare
      end

      def message
        "%d commit%s by %s pushed to %s/%s: %s" % [
          commit_count,
          commit_count == 1 ? "" : "s",
          author_usernames.join(", "),
          repo_name,
          branch,
          compare_url
        ]
      end

    end

  end
end
