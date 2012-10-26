module IrcMachine
  module Models

    class GithubUser < OpenStruct
      @@nicks = Hash.new
      @@prefix = ""
      class << self
        def nicks=(mapping)
          @@nicks = mapping
        end

        def prefix=(prefix)
          @@prefix = prefix
        end
      end

      # Wrapper class that does a lookup based on usernames at init time

      def nick
        @@nicks[username] || username
      end

      def to_s
        "#{@@prefix}#{nick}"
      end
    end

  end
end
