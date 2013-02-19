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

Here we have collected best practices on how to install Plone in various situations.

.. note::

   These instructions do not cover all possibilities,
   and may not cover all use cases.
   Please feel free to edit this document to add more.

Plone hosting requirements
========================================================

* You need at a least a virtual private server (VPS) with 512 MB RAM available.
  Shared hosting is not supported unless the shared hosting company says Plone is good to go.
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


How to install Plone
========================================================

Plone can run  on any modern desktop or server operating system:
Linux, OSX, BSD and Microsoft Windows.

* You can install Plone on the server for production usage

* You can install Plone locally on your own computer for the development and test drive

Ubuntu / Debian
----------------------------------------------------

Installing Plone using the Unified UNIX Installer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note::

  This is the recommended Plone installation method.

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

For further info see also `Plone manual for installing on UNIX <http://plone.org/documentation/manual/installing-plone/installing-on-linux-unix-bsd/>`_.

For information on using this installation with more advanced production
hosting environments and deployments,
see the :doc:`hosting guide </hosting/index>`.

Instructions are tested for the *Ubuntu 10.04 Long Term Support* release.

1. Create new UNIX user called ``plone``. This user will be the user who has the rights to Plone code and database files and will run Plone processes. You can use any normal UNIX user here as long as you have sudo rights to install necessary software to install and run Plone:

   .. code-block:: console

        # adduser plone

   .. note::

      It is not recommended to run or install Plone as the root user.
      There is nothing in Plone requiring root privileges.

2. Install operating system software needed to run Plone::


        sudo apt-get install python-distribute python-dev build-essential libssl-dev libxml2-dev libxslt1-dev libbz2-dev


    In newer versions of Ubuntu and from Debian 6 [Squeeze] on *python-distribute* is replaced by *python-setuptools*.

    You will probably also want these optional system packages (see `Plone manual for more information <http://plone.org/documentation/manual/installing-plone/installing-on-linux-unix-bsd/debian-libraries>`_)::


        sudo apt-get install libjpeg62-dev libreadline-gplv2-dev wv poppler-utils python-imaging


   Install also version control software needed often when developing with Plone::

        sudo apt-get install subversion git

   .. note::

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

        wget --no-check-certificate https://launchpad.net/plone/4.2/4.2.4/+download/Plone-4.2.4-UnifiedInstaller-r3.tgz

5. Run the Plone installer as non-root-userd, standalone‚ mode.:

   .. code-block:: console

        # Extract the downloaded file
        tar -xf Plone-4.2.4-UnifiedInstaller-r3.tgz
        # Go the folder containing installer script
        cd Plone-4.2.4-UnifiedInstaller
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

        cd ~/Plone/zinstance
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

* :doc:`ZopeSkel </getstarted/paste>`
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

The binary installer is intended to provide an environment suitable for testing, evaluating,
and developing theme and add-on packages. It will not give you the ability to add or develop
components that require a C compiler.

Installing Plone from source
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Installation via the Unified Installer or buildout is very similar to Unix. However, you will
need to install a command-line build environment. To get a free build kit from Apple, do one
of the following:

* Download gcc and command-line tools from
  https://developer.apple.com/downloads/. This will require an Apple
  developer id.

* Install Xcode from the App Store. After installation, visit the Xcode
  app's preference panel to download the command-line tools.

After either of these steps, you immediately should be able to install Plone
using the
Unified Installer. Note that with Plone 4.2.x, you may use the Python 2.7
that's shipped
with OS X via the ``--with-python`` option of the installer.

For OS X 10.6 and 10.7, you may avoid the Xcode install via these steps.

* Install Homebrew or Macports package manager.

* Install Python 2.7 (Plone 4.2.x) or 2.6 via the package manager.

Proceed as with Linux.

Entering debug mode after installation
=========================================

When you have Plone installed and want to start
development you need do :doc:`enter debug mode </getstarted/debug_mode>`.

Installer source code
======================

* https://github.com/plone/Installers-UnifiedInstaller

