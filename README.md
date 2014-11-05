This is a small rack application for batching GET requests to a json API, and
returning them in a single JSON string.

Development
-----------

To start the server:

    BG_API_ENDPOINT=api.example.com rackup

To make a request:

    curl localhost:9292 -XPOST -d'["item/1", "item/2", "item/3"]'

Batch getter will return a JSON array with the items in the same order. If any
of them return with a non 2xx response code, the item in the list will be null
instead.

Batch getter will pass cookie information on to the endpoint API, if any are
set. This would require batch getter running on the same domain as the end
point, or some clever trickery on the client to send the correct cookie.

It currently does very little error checking of the data sent in, so bad things
might happen if you send it some json that isn't a list of URLs, and if any of
those URLs return data that isn't in the JSON format.

Deployment
----------

This can easily be deployed as a war using Warbler. The warbler gem is included
so that it doesn't need to be installed to your global gems.

    bundle install
    bundle exec warble

This will create a batch\_getter.war file that can be deployed using your
application server of choice.

Deployment under MRI is left as an exercise for the reader.
