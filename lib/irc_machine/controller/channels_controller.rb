module IrcMachine
  module Controller
    class ChannelsController < HttpController

      def list
        content_type "application/json"
        ok session.state.channels.to_json << "\n"
      end

      def join
        session.join channel(match), request.GET["key"]
      end

      def part
        session.part channel(match)
      end

      def message
        m = request.body.gets
        session.msg channel(match), m.chomp if m
      end

      private

      def channel(match)
        "#" + match[1]
      end

    end
  end
end
