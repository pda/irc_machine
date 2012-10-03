class IrcMachine::Models::JuiciProject

  attr_reader :config, :name

  def initialize(name, config)
    @name = name
    @config = config
  end

  def build_script(project)
    projects[project]["build_script"] || <<-EOS #{{{
#!/bin/sh
#
if [ ! -d .git ]; then
  git init .
  git remote add origin https://github.com/#{project}.git
  git fetch origin
fi

git checkout $SHA1

./script/cibuild
EOS
#}}}
  end

  def build_payload(opts={})
    { #{{{
      "project" => name,
      "environment" => opts["environment"] || {},
      "command" => build_script,
      "priority" => opts["priority"] || 1
    } #}}}
  end

end
