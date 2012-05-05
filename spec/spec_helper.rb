require 'irc_machine'
require 'mocha'

Dir["#{File.expand_path(File.dirname(__FILE__))}/helpers/**/*.rb"].each do |f|
  puts "Requiring #{f}"
  require f
end

RSpec.configure do |config|
  config.mock_with :mocha
end
