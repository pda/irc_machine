# Your configuration should look something like:
# - {
#     "notication_name": "echo 'test'",
#     "some_other_notification": [
#       "Do this thing",
#       "and also this thing"
#     ]
#   }
class IrcMachine::Plugin::Notifier < IrcMachine::Plugin::Base
  CONFIG_FILE = "notifier.json"

  def notify(event)
    case value = settings[event]
    when Array
      value.each do |n|
        execute(n)
      end
    when String
      execute(value)
    end
  end

  def execute(command)
    Kernel.system "#{command} &"
  end

end
