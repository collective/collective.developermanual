=======================
 Installation
=======================

.. admonition:: Description

    Installatioin instructions for Plone for various
    operating systems and situations. 

.. contents :: :local:

.. highlight:: console

Introduction
=============

Here we have collected best practices how to install Plone in various situations.

.. note ::

  These instructions are not all-inclusive and may not cover all use cases. 
  Please feel free to edit this document to add more.

How to host Plone
--------------------------------------------------------

* You need at least `a virtual private server with 512 MB RAM, shared hosting is a no-go <http://plone.org/documentation/kb/plone-system-requirements>`_

* Linux Server is the recommended option. Ubuntu / Debian 64-bit environment is the most popular and has the most support

* You also might want to configure :doc:`a front-end web server </hosting/index>` besides Plone. In most Linux environments
  the distribution has an out of the box configuration for this front-end web server to handle port 80 HTTP traffic.
  This front-end web server proxies the traffic, inside the server, to Plone listening on another port (port 8080 by default).

.. note ::

  It is possible to host Plone on Microsoft Windows too.
  Other operating system production installations are possible, but rarer.


How to develop Plone
--------------------------------------------------------

Plone development can be done on any modern desktop operating systems.
The recommended method is to develop on your local computer and then push changes to the server as Plone add-on.

* You install Plone on the server for production

* You install Plone locally for development

* Then you push any required Plone customizations to the server using your
  own customization add-on

Please see :doc:`Creating your first theme / add-on </tutorials/addon>`.

Ubuntu / Debian
====================================================

Installing Plone using Unified UNIX Installer 
--------------------------------------------------------

.. note ::

  This is the recommended installation method
  
This recipe is good for

* Lightweight production sites

* Plone development and testing on Ubuntu / Debian  

The resulting installation is self-contained, 
does not touch system files and is safe to play with (no root/sudoing in needed).

For information on using this installation with more advanced production hosting environments and deployments, 
see the :doc:`hosting guide </hosting/index>`.

Instructions tested for Ubuntu 10.04 Long Term Support release.

Create new UNIX user (e.g. user ``plone``)::

     adduser plone

.. note ::

   It is not recommended to run or install Plone under root user.
   There is nothing in Plone requiring root priviledges.

Install operating system prerequisitements::

     sudo apt-get install python-dev build-essential libssl-dev

Log-in as this user::

     sudo -i -u plone

Download Plone unified binary from `download page to your server <http://plone.org/download>`_

     wget https://launchpad.net/plone/4.1/4.1.4/+download/Plone-4.1.4-UnifiedInstaller.tgz

Run the installer as non-root standalone mode::
   
     ./install.sh standalone

Admin username is printed in the console. You can change this password after logging
into the Zope Management Interface. 

.. note ::

    The password is also written down in buildout.cfg file, but this setting is not 
    effective after Plone has been started for the first time. Changing this setting
    does not do any good.

Start Plone in development mode for a test run (you'll see potential errors in the console)::

     cd ~/Plone/
     bin/instance fg

By default, Plone will listen to all available network interfaces and port 8080.

Now enter to Plone site by entering address 

     http://yourserver:8080 

... to your webbrowser.

Zope, the application server under Plone, will ask you to create a new site.
For this you need the login credentials outputted into your terminal earlier.

If everything is ok press *CTRL + C* in the terminal to stop Plone in debug mode.

Then start Plone in production mode. In the production mode 
Plone does not reload file changes on the file system and also stays running even if you
disconnect the terminal session::
  
    bin/instance start
  
If you have problems and need help, `please see the help guidelines <http://plone.org/help>`_.

For automatic start-ups on server boot-up, init scripts, more advanced hosting, etc.
please see the :doc:`hosting guide </hosting/index>`. 

Installing Plone using buildout on Ubuntu / Debian
--------------------------------------------------------

Here are quick instructions to install Plone using buildout and OS provided Python interpreter.
You need to manage dependencies (libxml, Pillow) yourself.

This will:

* create a default ``buildout.cfg`` configuration file and folder structure
  around it;
* automatically download and install all packakges from `pypi.python.org <pypi.python.org>`_
* configure Plone and Zope for you.

Install virtualenv for python (on Ubuntu)::

      sudo apt-get install python-virtualenv

Create a virtualenv where you can install some Python packages (ZopeSkel,
Pillow)::
  
      virtualenv plone-virtualenv

In this virtualenv install ZopeSkel (from the release 2 series)::

    source plone-virtualenv/bin/activate
    easy_install "ZopeSkel<2.99"

Create Plone buildout project using ZopeSkel::

    paster create -t plone4_buildout myplonefolder

Optionally edit buildout.cfg in this point.
Run buildout (use Python 2.6 for Plone 4.1)::

    python2.6 bootstrap.py
    bin/buildout

More info:

* :doc:`ZopeSkel </tutorials/paste>` 
* `virtualenv <http://pypi.python.org/pypi/virtualenv>`_ 
* `Pillow <http://pypi.python.org/pypi/Pillow/>`_ 
* `lxml <http://lxml.de/>`_

Installing Plone using Ubuntu / Debian .deb packages
--------------------------------------------------------

Not supported by Plone community.

(i.e. no one does it)

Microsoft Windows
=========================

Installing Plone on Windows
--------------------------------------------------------

For Plone 4.1 on forward see these instructions

* https://docs.google.com/document/d/19-o6yYJWuvw7eyUiLs_b8br4C-Kb8RcyHcQSIf_4Pb4/edit

If you wish to develop Plone on Windows you need to set-up a working MingW environment (painful)

* http://plone.org/documentation/kb/using-buildout-on-windows

OSX
====================================================

Installing Plone using OSX binary installer
--------------------------------------------------------

This is the recommended method if you want to try Plone for the first time.

Please use the installer from the download page `<http://plone.org/products/plone/releases>`_.

Installing Plone using buildout 
--------------------------------------------------------

This is a good method for doing Plone development on OSX.

* Install Homebrew or Macports package manager

* Install Python 2.6 via the package manager

* Install `virtualenv <http://pypi.python.org/pypi/virtualenv>`_ via the package manager

* Under this virtualenv, install ZopeSkel (not version 3)::

     virtualenv -p python2.6 my-plone-python-env
     source my-plone-python-env/bin/activate
     easy_install "ZopeSkel<2.99"

* Then bootstrap Plone 4 installation (using still virtualenv`d python)::

     bin/paster create -t plone4_buildout your-installation-folder
     cd your-installation-folder
     python bootstrap.py
     bin/buildout

