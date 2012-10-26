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
        data.ref.gsub(%r{refs/(heads|tags)/}, "")
      end

      def tag?
        data.ref.start_with? "refs/tags/"
      end

      def after
        data.after
      end

      def before
        data.before
      end

      def commits
        data.commits
      end

      def owner
        OpenStruct.new(repository.owner)
      end

      def repository
        OpenStruct.new(data.repository)
      end

      def authors
        data.commits.map{ |c| ::IrcMachine::Models::GithubUser.new c["author"] }
      end

      def author_usernames
        authors.map{ |a| a.username }.uniq
      end

      def author_nicks
        authors.map{ |a| a.nick }.uniq
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

      def project
        "#{owner.name}/#{repo_name}"
      end

      def ref
        data.ref
      end

      def pusher
        # The last commit is probably the person who pushed the branch
        push_commit = commits.last
        return nil if push_commit.nil?
        push_user = ::IrcMachine::Models::GithubUser.new push_commit["author"]
        push_user.nick
      end

    end

  end
end
