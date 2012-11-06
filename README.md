Agent99
=======

[99designs](https://99designs.com) helpful IRC bot, built on top of [IRC Machine](https://github.com/pda/irc_machine), in turn on Ruby and [EventMachine](http://rubyeventmachine.com/).


Plugins
-------

Plugins are objects which respond to `#receive_line`, and would will receive a reference to the `IrcMachine::Session` when instantiated. It should use that reference to send IRC commands.

Plugins may also implement the RESTful HTTP API by creating routes. The pattern for this would look something like:

```ruby

def initialize(*args)
  route(:get, "/endpoint", :endpoint)
  super(*args)
end

def endpoint(request, match)
  ok request.body.read
end
```

Configuration
-------------

You should copy `example.json` to `irc_machine.json`, or set `IRC_MACHINE_CONF` to the name of the config file.

Plugins are enabled by their class name specified in the `plugins` array, everything under `irc_machine/plugin` will be loaded at boot time, however.

Default Plugins
---------------

We ship agent99 with a small collection of useful plugins for integrating with the services with use- Github, JuiCI, Jenkins and the like.

We also ship a collection of totally unuseful plugins, for generating memes, using Google's images search or [yelling Yarr](http://99designs.com/tech-blog/blog/2012/09/19/talk-like-a-pirate-day/)

Contributors
------------

* [Richo Healey](https://github.com/richo)
* [Michael Mifsud](https://github.com/xzyfer)

### irc_machine originally by:

* [Paul Annesley](https://github.com/pda)
* [Eric Anderson](https://github.com/ericanderson)
* [Anton Lindström](https://github.com/antonlindstrom)

Meh.
----

agent99 is:
© 99designs, 2012, [MIT license](http://www.opensource.org/licenses/mit-license.php)

All source code from irc_machine is:
© Paul Annesley, 2011, [MIT license](http://www.opensource.org/licenses/mit-license.php)
