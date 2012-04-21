IRC Machine
===========

An IRC bot with a RESTful HTTP interface, built on Ruby and [EventMachine](http://rubyeventmachine.com/).

Design philosophy: simple to the point of under-engineered, make it work for the 90% case.

    # something like this might work
    git clone git://github.com/pda/irc_machine
    cd irc_machine
    cp example.json irc_machine.json

    # run it
    ./bin/irc_machined run
    # ctrl+c

    # daemonize it
    ./bin/irc_machined start
    # stop the daemon
    ./bin/irc_machined stop

    # or maybe even this (chances aren't good, though)
    gem install irc_machine
    irc_machined run

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

Default Plugin
--------------

IrcMachine ships with a plugin to demonstrate the REST API. It listens on port 8421 by default. And you can't change the default.

* `GET /channels` returns a JSON list of channels the bot is probably in.
* `PUT /channels/{name}` joins a channel.
* `DELETE /channels/{name}` parts a channel.
* `POST /channels/{name}` sends a text/plain message to a channel, auto-joins if required.
* `POST /channels/{name}/github` accepts GitHub post-receive hook notifications, notifies channel.


Contributors
------------

* [Paul Annesley](https://github.com/pda)
* [Eric Anderson](https://github.com/ericanderson)
* [Anton Lindström](https://github.com/antonlindstrom)
* [Richo Healey](https://github.com/richoH)


Meh.
----

© Paul Annesley, 2011, [MIT license](http://www.opensource.org/licenses/mit-license.php)
