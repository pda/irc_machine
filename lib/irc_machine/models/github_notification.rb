require "json"
require "cgi"
require "ostruct"

module IrcMachine
  module Models

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

      def last_commit_message
        data.commits.last["message"]
      end

      def message
        "%d commit%s by %s (%s) pushed to %s/%s: %s" % [
          commit_count,
          commit_count == 1 ? "" : "s",
          author_usernames.join(", "),
          last_commit_message
          repo_name,
          branch,
          compare_url
        ]
      end

    end

  end
end
