$LOAD_PATH << File.dirname(__FILE__)

%w{
  eventmachine
  evma_httpserver
  evma_httpserver/response
  rack
}.each do |name|
  require name
end

%w{
  commands
  connection
  session
  plugin
  plugin/base
  plugin/reloader
}.each do |name|
  require "irc_machine/#{name}"
end
