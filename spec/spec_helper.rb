require 'rspec'
require 'irc_machine'
require 'mocha'

require 'fileutils'

Dir["#{File.expand_path(File.dirname(__FILE__))}/helpers/**/*.rb"].each do |f|
  puts "Requiring #{f}"
  require f
end

require File.expand_path("../../lib/irc_machine/monkey_patches.rb", __FILE__)

RSpec.configure do |config|
  config.mock_framework = :mocha
end
