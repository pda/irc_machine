require 'net/http'
require 'json'
class IrcMachine::Models::JuiciProject

  attr_reader :config, :name

  def initialize(name, config)
    @name = name
    @config = config || {}
  end

  def build_script
    config["build_script"] || <<-EOS #{{{
#!/bin/sh
#
if [ ! -d .git ]; then
  git init .
  git remote add origin https://github.com/#{name}.git
fi
git fetch origin

git checkout -fq $SHA1

./script/cibuild
EOS
#}}}
  end

  def build_payload(opts={})
    URI.encode_www_form({ #{{{
      "project" => name,
      "environment" => (opts[:environment] || {}).to_json,
      "command" => build_script,
      "priority" => opts[:priority] || 1,
      "callbacks" => (opts[:callbacks] || []).to_json,
      "title" => opts[:title]
    }) #}}}
  end

  def priorities
    config["priorities"] || {}
  end

end
