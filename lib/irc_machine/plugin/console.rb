# A basic websocket console that just dumps all recieved lines to a console

class IrcMachine::Plugin::Console < IrcMachine::Plugin::Base

  attr_reader :pool
  def initialize(*args)
    super(*args)

    @pool = []
    route(:get, "/console", :serve_console_html)
    bind(:websocket, 9001, console_server)
  end

  def receive_line(line)
    pool.each do |sock|
      sock.send(">> #{line}")
    end
  end

  def console_server
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

  def serve_console_html(request, match)
    ok <<-HTML, content_type: "text/html"
<html>
<head>
<script type="text/javascript">

  function log(data) {
    var log    = document.querySelector("#logger");
    log.innerHTML = data + "\\n" + log.innerHTML;
  }

  function websocketInit(window, document) {
    if ("WebSocket" in window) {
      ws_host = "ws://"+window.location.hostname+":9001";
      ws = new WebSocket(ws_host);
      ws.onmessage = function(event) {
        log(event.data);
      };
    } else {
      // the browser doesn't support WebSocket
      alert("WebSocket NOT supported here!\\r\\n\\r\\nBrowser: " +
          navigator.appName + " " + navigator.appVersion);
    }
    return false;
  }
</script>
</head>
<body>
<div>
<pre id="logger">
<script>websocketInit(window, document)</script>
</pre>
</div>
</body>
</html>
HTML
  end
end

