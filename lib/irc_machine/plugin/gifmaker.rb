require 'json'
class IrcMachine::Plugin::GifMaker < IrcMachine::Plugin::Base
  def initialize(*args)
    super(*args)
    route(:post, "/gifmaker", :gimme_gif)
  end

  def gimme_gif(request, match)
    url = request.body.read
    session.msg "#melb", url
  end
end
