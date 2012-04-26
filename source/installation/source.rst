=======================
 Installation
=======================

.. admonition:: Description

    Installation instructions for Plone for various
    operating systems and situations. 

.. contents:: :local:

.. highlight:: console

Introduction
=============

Here we have collected best practices how to install Plone in various situations.

.. note::

  These instructions do not cover all possibilities, 
  and may not cover all use cases. 
  Please feel free to edit this document to add more.

How to host Plone
========================================================

* You need at a least virtual private server with 512 MB RAM. 
  Shared hosting is a no go.
  See the reference on 
  `Plone system requirements <http://plone.org/documentation/kb/plone-system-requirements>`_.

* A Linux server is the recommended option.
  Ubuntu / Debian 64-bit environment is the most popular and has most support.

* You also might want to configure 
  :doc:`a front-end web server </hosting/index>` besides Plone.
  In most Linux environments the distribution is configured out-of-the-box 
  for this front-end web server to handle HTTP traffic on port 80.
  This front-end web server proxies the traffic to Plone running on another
  port (port 8080 by default).

.. note::

  It is possible to host Plone on Microsoft Windows too.
  Other operating system production installations are possible, but rarer.


How to install Plone for testing or developmenet
========================================================

Plone development can be done on any modern desktop operating system.
The recommended Plone development method is to develop on your local computer
and then push changes to the server as Plone add-on.

* You install Plone on the server for production.
* You install Plone locally for the development.
* Then you push any required Plone customizations to the server using your
  own customization add-on.

Please see :doc:`Creating your first theme / add-on </tutorials/addon>`.

Ubuntu / Debian
----------------------------------------------------

Installing Plone using the Unified UNIX Installer 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note::

  This is the recommended installation method.
  
This recipe is good for:

* Lightweight production sites

* Plone development and testing on Ubuntu / Debian

* Operating system installations where you have administrator (root) access. Note that  
  root access is not strictly necessary as long as you have required software installed
  beforehand on the server, but this tutorial assumes you need to install the software 
  yourself and you are the admin.

The resulting installation is self-contained, 
does not touch system files, 
and is safe to play with (no root/sudoing is needed).

If you are not familiar with UNIX operating system commad line
you might want to study this `Linux shell tutorial <http://linuxcommand.org/learning_the_shell.php>`_
first.

Instructions are tested for the *Ubuntu 10.04 Long Term Support* release.

1. Create new UNIX user called ``plone``. This user will be the user who has the rights to Plone code and database files and will run Plone processes. You can use any normal UNIX user here as long as you have sudo rights to install necessary software to install and run Plone:

   .. code-block:: console

        # adduser plone

For information on using this installation with more advanced production
hosting environments and deployments, 
see the :doc:`hosting guide </hosting/index>`.

Instructions tested for Ubuntu 10.04 Long Term Support release.

.. note::

   It is not recommended to run or install Plone as the root user.
   There is nothing in Plone requiring root privileges.

2. Install operating system software needed to run Plone:

   .. code-block:: console

        sudo apt-get install python-dev build-essential libssl-dev wget

.. note ::

    If sudo command is not recognized or does not work you don't have administrator rights to 
    Ubuntu / Debian operating system. Please contact your server vendor or consult the operating
    system support forum.

3. Log-in as plone user under which the installed software will run. Note that you need to rerun this command later
if you want to adjust Plone settings or run start or stop commands for Plone:

   .. code-block:: console

        sudo -i -u plone

4. Download the Plone binary installer
   from the `download page <http://plone.org/download>`_ to your server using wget command.

   .. code-block:: console

        wget --no-check-certificate https://launchpad.net/plone/4.1/4.1.4/+download/Plone-4.1.4-UnifiedInstaller.tgz
       
5. Run the Plone installer as non-root-userd, standalone‚ mode.:

   .. code-block:: console
   
        # Extract the downloaded file 
        tar -xf Plone-4.1.4-UnifiedInstaller.tgz
        # Go the folder containing installer script
        cd Plone-4.1.4-UnifiedInstaller
        # Run script
        ./install.sh standalone

   The default admin credentials will be printed to the console.
   You can change this password after logging in to the Zope Management Interface. 
   
   .. note::
   
       The password is also written down in the ``buildout.cfg`` file, but this
       setting is not effective after Plone has been started for the first time.
       Changing this setting does not do any good.

6. Start Plone in the foreground for a test run (you'll see potential errors in the console):

   .. code-block:: console

        cd ~/Plone/
        bin/instance fg

When you start Plone in the foreground, it runs in debug mode: 
somewhat slower and a lot more informative than production mode.

By default, Plone will listen to port 8080 on available network interfaces.

7. Now enter the Plone site by visiting the following address in your webbrowser::

     http://yourserver:8080 

   Zope, the application server underlying Plone, will ask you to create a new site.
   For this you need the login credentials printed to your terminal earlier.
   
   If everything is OK, press ``CTRL-C`` in the terminal to stop Plone.

8. Then start Plone in production mode.
   In production mode, Plone does not reload file changes on the file system and
   also stays running even if you disconnect the terminal session:

   .. code-block:: console
  
        bin/instance start
  
If you have problems, please see the `help guidelines <http://plone.org/help>`_.

For automatic start-up when your server boots up, init scripts, etc.
please see the :doc:`hosting guide </hosting/index>`. 

Installing Plone using buildout on Ubuntu / Debian
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Here are quick instructions to install Plone using buildout and the OS-provided
Python interpreter.
You need to manage dependencies (``libxml``, ``Pillow``) yourself.

This will:

* create a default ``buildout.cfg`` configuration file and folder structure
  around it;
* automatically download and install all packages from `pypi.python.org <pypi.python.org>`_;
* configure Plone and Zope for you.

1. Install ``virtualenv`` for python (on Ubuntu):

   .. code-block:: console

        sudo apt-get install python-virtualenv

2. Create a ``virtualenv`` where you can install some Python packages
   (``ZopeSkel``, ``Pillow``):

   .. code-block:: console
  
        virtualenv plone-virtualenv

3. In this virtualenv install ``ZopeSkel`` (from the release 2 series):

   .. code-block:: console

        source plone-virtualenv/bin/activate
        easy_install "ZopeSkel<2.99"

4. Create Plone buildout project using ZopeSkel:

   .. code-block:: console

        paster create -t plone4_buildout myplonefolder

5. Optionally edit ``buildout.cfg`` at this point.
   Run buildout (use Python 2.6 for Plone 4.1):

   .. code-block:: console

    python2.6 bootstrap.py
    bin/buildout

More info:

* :doc:`ZopeSkel </plugins/paste>`
* `virtualenv <http://pypi.python.org/pypi/virtualenv>`_ 
* `Pillow <http://pypi.python.org/pypi/Pillow/>`_ 
* `lxml <http://lxml.de/>`_

Installing Plone using Ubuntu / Debian .deb packages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Not supported by Plone community.

(i.e. no one does it)

.. Except for Enfold.

Microsoft Windows
-------------------------

Installing Plone on Windows
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For Plone 4.1 and later, see these instructions:

* https://docs.google.com/document/d/19-o6yYJWuvw7eyUiLs_b8br4C-Kb8RcyHcQSIf_4Pb4/edit

If you wish to develop Plone on Windows you need to set-up a working MingW
environment (this can be somewhat painful if you aren't used to it):

* http://plone.org/documentation/kb/using-buildout-on-windows

OSX
----------------------------------------------------

Installing Plone using OSX binary installer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is the recommended method if you want to try Plone for the first time.

Please use the installer from the download page `<http://plone.org/products/plone/releases>`_.

Installing Plone using buildout 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is a good method for doing Plone development on OSX.

* Install Homebrew or Macports package manager.

* Install Python 2.6 via the package manager.

* Install `virtualenv <http://pypi.python.org/pypi/virtualenv>`_ via the package manager.

* Under this virtualenv, install ZopeSkel (not version 3):

  .. code-block:: console

    virtualenv -p python2.6 my-plone-python-env
    source my-plone-python-env/bin/activate
    easy_install "ZopeSkel<2.99"

* Then bootstrap Plone 4 installation (using the python interpreter in your
  virtualenv):

  .. code-block:: console

     bin/paster create -t plone4_buildout your-installation-folder
     cd your-installation-folder
     bin/python bootstrap.py
     bin/buildout

