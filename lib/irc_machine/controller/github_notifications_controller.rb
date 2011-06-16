module IrcMachine
  module Controller
    class GithubNotificationsController < HttpController

      def notify
        session.msg "##{match[1]}",
          Plugin::GithubNotification.new(request.body.read).message
      end

    end
  end
end
