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

      def notification_format(build_status)
        compare_prefix = if commit.repository.url
                            commit.repository.url + "/compare/"
                         else
                           ""
                         end
        "Build of #{commit.repo_name.irc_bold}/#{commit.branch.irc_bold} was a #{build_status} #{compare_prefix}#{commit.before[0..6]}...#{commit.after[0..6]} in #{build_time.irc_bold}s PING #{users_to_notify.join(" ")}"
      end

    end

  end
end
