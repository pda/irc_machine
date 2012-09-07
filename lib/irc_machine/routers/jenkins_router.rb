
class IrcMachine::Routers::JenkinsRouter < IrcMachine::Routers::Base
  def get_build(message)
    ::IrcMachine::Models::JenkinsNotification.new(message)
  end
end
