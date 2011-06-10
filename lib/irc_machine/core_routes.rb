module IrcMachine
  module CoreRoutes

    CHANNEL_REGEXP ||= %r{^/channels/([\w-]+)$}

    def draw_routes(router)
      router.draw do
        get "/channels" do
          content_type "application/json"
          ok session.state.channels.to_json << "\n"
        end

        put CHANNEL_REGEXP do |match|
          session.join channel(match), request.GET["key"]
        end

        delete CHANNEL_REGEXP do |match|
          session.part channel(match)
        end

        post CHANNEL_REGEXP do |match|
          m = request.body.gets
          session.msg channel(match), m.chomp if m
        end
      end

      router.helpers do
        def channel(match)
          "#" + match[1]
        end
      end

    end

  end
end
