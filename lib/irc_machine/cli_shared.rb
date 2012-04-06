require "json"
require 'irc_machine/monkey_patches'
require 'irc_machine'

ENV['IRC_MACHINE_CONF'] ||= File.expand_path("./irc_machine.json")
IRC_MACHINE = JSON.load(open(ENV['IRC_MACHINE_CONF'])).symbolize_keys