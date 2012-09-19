# This is not a valid plugin, it can't be directly attached to an endpoint.
#
# I just couldn't work out where else this code belonged.
#
# Usage:
#  def initialize_jenkins_notifier
#    @notifier = JenkinsNotifier.new(@commits) do |endpoint|
#      endpoint.on :success do |commit, build|#{{{ Success
#        notify format_msg(commit, build)
#      end #}}}
#
#      endpoint.on :failure do |commit, build| #{{{ Failure
#        notify format_msg(commit, build)
#        notify "Jenkins output available at #{build.full_url}"
#      end #}}}
#    end
#  end
#
#  With subsequent calls to
#  @notifier.process([body of jenkins notification])
class IrcMachine::Routers::Base
  attr_reader :commits, :triggers
  def initialize(commits)
    @commits = commits
    @triggers = {}
    if block_given?
      yield self
    end
  end

  def process(message, &block)
    build = get_build(message)

    if block_given?
      yield build
    end

    if match = triggers[build.phase.downcase.to_sym]
      if commit = @commits[build.parameters.ID.to_s]
        if block = match[build.status.downcase.to_sym] rescue nil
          block.call(commit, build)
        elsif block = match[:any]
          block.call(commit, build)
        end
      else
        if block = triggers[:unknown][:any]
          block.call(build)
        end
      end
    end
  end

  def on(phase, status=:any, &block)
    triggers[phase] ||= {}
    triggers[phase][status] = block
  end

  def get_build(message)
    raise "Undefined method get_build"
  end

  def endpoint
    lambda { |request, match| process(request.body.read) }
  end
end

