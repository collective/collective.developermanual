===================================================
Tutorial: Installing Plone for Production on Ubuntu
===================================================

.. admonition:: Description

    A step-by-step guide to installing Plone 4.x on a recent Ubuntu LTS [12.04] server installation.

.. contents:: :local:

Introduction
------------

This tutorial walks you step-by-step through a minimum responsible installation of Plone for production on a recent Ubuntu LTS server.

The installation includes Plone itself; nginx for a reverse-proxy; a send-only mail-transfer agent; and firewall rules. We'll set Plone to start with server startup and will add cron jobs to periodically pack the database and create snapshot backups.

This minimal install will work for production for a smaller Plone site, and will provide a good base for scaling up for a larger site.

Requirements
^^^^^^^^^^^^

1. A clean installation of a recent Ubuntu server. The tutorial has been tested on cloud and virtual box servers. The install described here will run in 512 MB RAM. More RAM will be needed for larger or busy sites.

2. A hostname for the new site. You or your DNS admin should have already created a hostname (e.g., www.yoursite.com) and a host record pointing to the new server.

3. Unix command-line and basic system administrator skills. You should know how to use `ssh` to create a terminal session with your new server. You should know how to use `vi` or some other terminal editor.

4. An Internet connection.

Step 1: Platform preparation
----------------------------

Get to the point where you can ssh to the server as a non-root user and use `sudo` to gain root permissions.

First step with any new server is to update the already installed system libraries:

.. code-block:: console

    sudo apt-get update
    sudo apt-get dist-upgrade

Then, install the platform's build kit, nginx, and supervisor:

.. code-block:: console

    sudo apt-get install build-essential python-dev libz-dev libjpeg-dev libxslt-dev supervisor nginx
    
Step 2: Install Plone
---------------------

Check `http://plone.org/products/plone <http://plone.org/products/plone>`_. Follow the `Download` link to get to the latest release. Copy the URL for the `Unified Installer`. Substitute that URL below:

.. code-block:: console

    wget https://launchpad.net/plone/4.3/4.3.2/+download/Plone-4.3.2-UnifiedInstaller.tgz

Unpack, change into the unpack directory and run the installer:

.. code-block:: console

    tar xf Plone-4.3.2-UnifiedInstaller.tgz
    cd Plone-4.3.2-UnifiedInstaller/
    sudo ./install.sh zeo

This will install Plone to /usr/local/Plone. There are installer options to put it elsewhere. Run `./install.sh`` with no arguments to get options.

.. note::

    Note that this is `root` installation. The installer will create special system users to build and run Plone.

.. note::

    This creates a `zeo` installation with two Plone clients. We will only connect one of those clients to the Internet. The other will be reserved for debugging and administrator access. If you know this is a larger site and wish to use load balancing, you may create more clients with the `-
