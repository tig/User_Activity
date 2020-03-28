# User Activity Driver for Control4

By Charlie Kindel ([@ckindel on Twitter](http://www.twitter.com/ckindel)) - Copyright © 2020 [Control4](http://www.contol4.com)

This is a simple driver for Control4 for interfacing with [MCE Controller](https://github.com/tig/mcec). MCE Controller provides robust remote control a Windows PC over the network. This driver allows you to use a home PC as a sensor for things like occupancy detection in a room.

## How To Use
Add the driver to a project. Use the `Activity Detected` event in programming, like this:

![programming](https://i.imgur.com/v8wmZm6.png)

NOTE: The driver currently exposes a `CONTACT_SENSOR` binding. However, **that is not coded up yet so it does not actually work.**

Set `MCE Controller` to connect to port `10001` on the controller, like this:

![settings](https://i.imgur.com/fKvFURM.png)


