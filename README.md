This is a small rack application for batching GET requests to a json API, and
returning them in a single JSON string.

This may be useful for an API that you need to request lots of items from that
doesn't natively support returning an array of items (it can also return arrays
of unrelated items that the API may not be able to combine).

It will not reduce the load on the server, as it will still have to produce the
same elements, but it should reduce the number of requests you need to make.

Development
===========

The gem dependencies can be installed using bundler. Development can be done on
Jruby or MRI. A version of ruby greater than 1.9 is needed.

If you need to run on 1.8, it is probably possible by adjusting the syntax and
locking the required gems to earlier versions.

To start the server:

    bundle install
    API_ENDPOINT=api.example.com bundle exec rackup

or

    bundle install --binstubs=bundler/bin
    API_ENDPOINT=api.example.com bundler/bin/rackup

Tests
=====

TODO

Manually tested against a proprietry API. Need to create some tests, and a mock
REST API to run some tests against.

Usage
=====

To make a request:

    curl localhost:9292 -XPOST -d'["item/1", "item/2", "item/3"]'

Batch getter will return a JSON array with the items in the same order, as if
the following requests had been made:

    GET api.example.com/item/1
    GET api.example.com/item/2
    GET api.example.com/item/3

Non 2xx response code will return a JSON string with the body, and a status, if
possible, otherwise it will return null.

If you prefer the whole request to fail for certain error codes, you can add
these to config (see below).

Batch getter will pass cookie information on to the endpoint API, if any are
set. This would require batch getter running on the same domain as the end
point, or some clever trickery on the client to send the correct cookie.

Config
======

Batch getter can be configured by environment variables, or by a yaml or ini
config file.

The following are currently configurable:

- api\_endpoint - The backend where GET requests will be sent.

- strict\_fail\_codes - An array of codes that will halt the whole request, and
  be sent back as the response for the whole response. (e.g., if the first
  request is Unauthorized, its probable that the preceeding ones will be too,
  so it may be beneficial to fail when it received the first one).

The location of the config file can be specified by the environment variable
`BG_CONFIG_LOCATION`. If `RACK_ENV` is set, it defaults to
`/etc/batch_getter/config.ini`.

Deployment
==========

JRuby / War
-----------

This can easily be deployed as a war using Warbler. The warbler gem is included
so that it doesn't need to be installed to your global gems.

    bundle install
    bundle exec warble

This will create a batch\_getter.war file that can be deployed using your
application server of choice.

In this mode, instead of using environment variables, the app will look for a
config file located at:

    /etc/batch_getter/config.ini

This should have the setting:

    api_endpoint=api.example.com

This is a standard location for \*nix applications, but I'm not sure if it is
standard for war deployments. There may be a better location that I'm not aware
of.

MRI
---

Deployment under MRI is left as an exercise for the reader.


Bugs
====

Probably.

Please create an issue if you find one.
