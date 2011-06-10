module IrcMachine
  module Controller
    class GithubNotificationsController

      def notify
        session.msg "##{match[1]}",
          GithubNotification.new(request.body.read).message
      end

    end
  end
end
