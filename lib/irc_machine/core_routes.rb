module IrcMachine
  module CoreRoutes

    CHANNEL_REGEXP ||= %r{^/channels/([\w-]+)$}

    def draw_routes
      get "/channels", "ChannelsController#list"
      put CHANNEL_REGEXP, "ChannelsController#join"
      delete CHANNEL_REGEXP, "ChannelsController#part"
      post CHANNEL_REGEXP, "ChannelsController#message"

      post %r{^/channels/([\w-]+)/github$}, "GithubNotificationsController#notify"
    end

  end
end
