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
    end
  end
end
