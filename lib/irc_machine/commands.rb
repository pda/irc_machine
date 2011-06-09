module IrcMachine
  module Commands

    def raw(raw)
      puts ">> #{raw}"
      irc_connection.send_data "#{raw}\r\n"
    end

    def user(user, name); raw "USER #{user} 8 * :#{name}"; end
    def nick(nick); raw "NICK #{nick}"; end
    def join(channel); raw "JOIN #{channel}"; end
    def part(channel); raw "PART #{channel}"; end
    def quit(reason); raw "QUIT :#{reason}"; end
    def msg(to, text); raw "PRIVMSG #{to} :#{text}"; end

  end
end
