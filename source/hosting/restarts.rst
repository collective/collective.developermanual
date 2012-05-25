============================
 Automatic Plone (re)starts
============================

.. contents:: :local:

Introduction
============

Tips how to (re)start Plone sites.

Restart script
==============

Restart command for Plone installations is 
``yourbuildoutfolder/bin/instance restart``.

It is best practice to run Plone as a non-root user.
Thus you need a special restart script which will ``sudo`` to this user
to perform the restart command. Due to egg cache problems, the 
``HOME`` environment variable must be considered when switching users.

Example ``/srv/plone/yoursite/restart-all.sh``:

.. code-block:: sh

    #!/bin/sh        
    echo Going to user yourploneuser
    cd /srv/plone/yoursite        
    sudo -H -u yourploneuser bin/instance restart
        
.. note::

    ``restart-all.sh`` must be made executable: ``chmod u+x``.


Start on boot
=============

It is best practice to start Plone service if the server is rebooted.
This way your site will automatically recover from power loss etc. 


crontab
=======

These instructions apply for Debian-based Linuxes.

Example crontab of yourploneuser::

    @reboot /srv/plone/yoursite/bin/instance start

rc.local script
---------------

For Debian-based Linuxes, add the following line to the ``/etc/rc.local`` script::

    /srv/plone/yoursite/restart-all.sh


Nightly restart
===============

Plone 3 leaks memory. It is best practice to restart the instance nightly,
or eventually you will run out of swap space.
Before running out of swap space, everything will come to grinding halt.

If nightly restart is not an option and you need high-availability instance, 
consider using ZEO clustering and
restart instances one-by-one with certain intervals.

Cron restart script
-------------------

Cron is a scheduled task daemon for Unix.

These instructions apply for Debian-based Linuxes.

Example ``/etc/cron.d/site`` script::

    # Restart varnish + deliverance + plone
    
    # run every night
    0 22 * * *     root     /srv/plone/yoursite/restart-all.sh
        


       


 
