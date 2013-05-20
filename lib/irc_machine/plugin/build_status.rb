require 'json'
class IrcMachine::Plugin::BuildStatus < IrcMachine::Plugin::Base
  def initialize(*args)
    super(*args)

    bind(:websocket, 9008, notifier_backend)
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
    if event[:project] == "99designs/contests"
      pool.each do |sock|
        sock.send(event.to_json)
      end
    end
  end

end
