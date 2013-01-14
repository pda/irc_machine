# Your configuration should look something like:
# - {
#     "notication_name": "echo 'test'",
#     "some_other_notification": [
#       "Do this thing",
#       "and also this thing"
#     ]
#   }
class IrcMachine::Plugin::Notifier < IrcMachine::Plugin::Base
  CONFIG_FILE = "notifier.json"

  attr_reader :pool
  def initialize(*args)
    super(*args)

    @pool = []
    bind(:websocket, 9002, notifier_backend)
  end

  def notifier_backend
    @server ||= Proc.new do |sock|
      sock.onopen do
        pool << sock
      end

      sock.onclose do
        pool.delete sock
      end

      sock.onerror do
        pool.delete sock
      end

      sock.onmessage do |msg|
        # Noop
      end
    end
  end

  def notify(event)
    pool.each do |sock|
      sock.send(event)
    end
  end
end
