require 'net/http'

module IrcMachine
  module Models

    class GithubCommit < OpenStruct

      def build_time
        (Time.now.to_i - start_time).to_s
      end

      def method_missing(sym, *args)
        # Make it the commit's problem
        self.commit.send(sym, *args)
      end

      def pusher
        # The last commit is probably the person who pushed the branch
        push_commit = commit.commits.last
        return nil if push_commit.nil?
        push_user = ::IrcMachine::Models::GithubUser.new push_commit["author"]
        push_user.nick
      end

      def users_to_notify
        authors.map(&:nick).flatten.uniq
      end

      def prefix
        @prefix ||= repository.url || "";
      end

      def github_url
        if tag?
          url = "#{prefix}/tree/#{branch}"
        else
          url = "#{prefix}/compare/#{before[0..6]}...#{after[0..6]}"
        end

        # Shorten if possible using git.io (Github's URL shortener)
        Net::HTTP.post_form(URI.parse('http://git.io'), {'url' => url})['Location'] rescue url
      end

    end
  end
end
