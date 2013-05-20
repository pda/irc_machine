require 'json'
class IrcMachine::Plugin::BuildStatus < IrcMachine::Plugin::Base
  attr_reader :pool
  def initialize(*args)
    super(*args)

    @pool = []
    bind(:websocket, 9008, notifier_backend)
    route(:post, "/buttan", :buttan)
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
      sock.send(event.to_json)
    end
  end

  def buttan(request, match)
    session.msg "#dev", "Someone pressed the buttan"
  end

end
