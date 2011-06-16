require "socket"

module IrcMachine

  class HttpServer < EM::Connection

    include EM::HttpServer

    attr_accessor :router

    def process_http_request
      send_response(*router.route(rack_env))
    rescue => e
      puts "!! #{self.class} rescued #{e.inspect}"
      puts "    " + e.backtrace.join("\n    ")
      send_response 500, {}, [ e.inspect, "\n" ]
    end

    def send_response(status, headers, body)
      EM::DelegatedHttpResponse.new(self).tap do |r|
        r.status = status
        r.headers = headers
        # Rack body is only guaranteed to respond to #each
        r.content = "".tap { |c| body.each { |b| c << b } }
        r.send_response
      end
    end

    def rack_env
      # TODO: map headers to HTTP_... keys.
      {
        "rack.version" => [1, 1],
        "rack.url_scheme" => @http_protocol,
        "rack.input" => StringIO.new((@http_post_content || "")),
        "rack.errors" => open("/dev/null", "w"), # muahaha
        "rack.multithread" => false,
        "rack.multiprocess" => false,
        "rack.run_once" => false,

        "REQUEST_METHOD" => @http_request_method,
        "SCRIPT_NAME" => "", # see PATH_INFO
        "PATH_INFO" => @http_path_info,
        "QUERY_STRING" => @http_query_string,
        "SERVER_NAME" => nil, # illegally nil
        "SERVER_PORT" => nil, # illegally nil
        "REMOTE_ADDR" => remote_ip, # not in spec

        "HTTP_COOKIE" => @http_cookie,
        "HTTP_IF_NONE_MATCH" => @http_if_none_match,
        "HTTP_CONTENT_TYPE" => @http_content_type,
        "HTTP_X_AUTH" => headers["X-Auth"],
      }
    end

    def remote_ip
      port, ip = Socket.unpack_sockaddr_in(get_peername)
      ip
    end

    def headers
      @headers ||= parse_headers(@http_headers)
    end

    # ghetto
    def parse_headers(header)
      header.split("\x00").inject({}) do |headers, line|
        headers[$1] = $2 if line =~ /^([^:]+):\s*(.*)$/
        headers
      end
    end

  end

end
