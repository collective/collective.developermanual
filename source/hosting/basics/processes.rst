Starting, Stopping and Restarting
=================================

Cluster Restarts
~~~~~~~~~~~~~~~~

Using multiple ZEO clients and a load balancer makes it possible to eliminate downtime
due to ZEO client restarts. There are many reasons why you might need to restart clients,
the most common being that you have added or updated an add-on product. (You should, of
course, have tested the new or updated package on a staging server.)

The basic procedure is simple: just restart your clients one at a time with a pause between each restart. This is usually scripted.

Load balancers, however, may raise issues. If your load balancer does not automatically handle temporary node downtime, you'll need to add to your client restart recipe a mechanism to mark clients as in down or maintenance mode, then mark them "up" again after a delay.

If your load balancer does handle client downtime, you may still need to make sure that it doesn't decide the client is "up" to early. Zope instances have a "fast listen" mode that causes them to accept HTTP requests very early in the startup process -- many seconds before they can actually furnish a response. This may lead your load balancer to diagnose the client as "up" and include it in the cluster. This can lead to some very slow responses. To improve the situation, turn off the "fast listen" mode in your client setup::

    [client1]
    recipe = plone.recipe.zope2instance
    ...
    http-fast-listen = off
    ...

If you are unable to tolerate slow responses during restarts, even this may not be good enough. Even after a Zope client is able to respond to requests, its first few page renderings will be slow while client database caches are primed. When speed sensitivity is this important, you'll want to add to your restart script a command-line request (via wget or curl) for a few sample pages. Do this after client restart and before marking the client "up" in the cluster. This is not commonly required.


