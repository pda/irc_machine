%w{
  ostruct
  eventmachine
  evma_httpserver
  evma_httpserver/response
  em-websocket
  rack
}.each do |name|
  require name
end

%w{
  commands
  irc_connection
  session
  state
  routers
  plugin
  plugin/base

  models

  core

  udp_server

  http_router
  http_server
}.each do |name|
  require "irc_machine/#{name}"
end

Dir[File.dirname(__FILE__) + '/irc_machine/models/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/irc_machine/routers/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/irc_machine/plugin/**/*.rb'].each {|file| require file }
