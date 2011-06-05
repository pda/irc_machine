$LOAD_PATH << File.dirname(__FILE__)

%w{
  commands
  connection
  session
  observer/base
  observer/die
  observer/hello
  observer/ping
  observer/reloader
  observer/verbose
  publisher/rest
  publisher/rest/server
}.each do |name|
  require "irc_machine/#{name}"
end
