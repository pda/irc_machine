$LOAD_PATH << File.dirname(__FILE__)

%w{
  ostruct
  eventmachine
  evma_httpserver
  evma_httpserver/response
  rack
}.each do |name|
  require name
end

%w{
  commands
  irc_connection
  session
  state
  plugin
  plugin/base
  plugin/reloader
}.each do |name|
  require "irc_machine/#{name}"
end
