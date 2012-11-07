# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "irc_machine/version"

Gem::Specification.new do |s|
  s.name        = "irc_machine"
  s.version     = IrcMachine::VERSION
  s.authors     = ["Paul Annesley"]
  s.email       = ["paul@annesley.cc"]
  s.homepage    = "https://github.com/pda/irc_machine"
  s.summary     = %q{irc machine}
  s.description = %q{An IRC bot using EventMachine, and perhaps ØMQ one day.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "eventmachine"
  s.add_dependency "eventmachine_httpserver"
  s.add_dependency "em-websocket"
  s.add_dependency "rack"
  s.add_dependency "daemons"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"

end
