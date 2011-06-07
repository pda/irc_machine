IRC Machine
===========

An IRC bot with a RESTful HTTP interface, built on Ruby and [EventMachine](http://rubyeventmachine.com/).

Design philosophy: simple to the point of under-engineered, make it work for the 90% case.

    # something like this might work
    git clone git://github.com/pda/irc_machine
    cd irc_machine
    cp example.json irc_machine.json
    ./bin/irc_machine

    # or maybe even this (chances aren't good, though)
    gem install irc_machine
    irc_machine


HTTP interface
--------------

The RESTful HTTP API is provided by `IrcMachine::Plugin::Rest`. It listens on port 8421 by default. And you can't change the default.

* `GET /channels` returns a JSON list of channels the bot is probably in.
* `PUT /channels/{name}` joins a channel.
* `DELETE /channels/{name}` parts a channel.
* `POST /channels/{name}` sends a text/plain message to a channel, auto-joins if required.
* `POST /channels/{name}/github` accepts GitHub post-receive hook notifications, notifies channel.


Plugins
-------

Plugins are objects which might respond to `#start` or `#receive_line`, and might use a reference to the `IrcMachine::Session` instance to send IRC commands.

In the future they might also be [ØMQ](http://www.zeromq.org/) endpoints, either in-process or over network. But not yet.


Meh.
----

© Paul Annesley, 2011, [MIT license](http://www.opensource.org/licenses/mit-license.php)
