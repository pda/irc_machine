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
}.each do |name|
  require "irc_machine/#{name}"
end
