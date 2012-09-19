module IrcMachine
  module Models

    class GithubUser < OpenStruct
      @@nicks = Hash.new
      class << self
        def nicks=(mapping)
          @@nicks = mapping
        end
      end

      # Wrapper class that does a lookup based on usernames at init time

      def nick
        @@nicks[username] || username
      end

      def to_s
        nick
      end
    end

  end
end
