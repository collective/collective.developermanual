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

2. Install operating system software needed to run Plone:

   .. code-block:: console

    sudo apt-get install python-distribute python-dev build-essential libssl-dev libxml2-dev libxslt1-dev libbz2-dev

   .. note::

      In newer versions of Ubuntu and from Debian 6 [Squeeze] on
      *python-distribute* is replaced by *python-setuptools*.

    You will probably also want these optional system packages (see `Plone manual for more information <http://plone.org/documentation/manual/installing-plone/installing-on-linux-unix-bsd/debian-libraries>`_):

    .. code-block:: console

        sudo apt-get install libjpeg62-dev libreadline-gplv2-dev wv poppler-utils python-imaging

    ..note::

      If you use Debian 6 [Squeeze] replace libreadline-gp1v2 with libreadline-dev


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

4. Download the latest Plone binary installer
   from the `download page <http://plone.org/download>`_ to your server using wget command.

   .. code-block:: console

        wget --no-check-certificate https://launchpad.net/plone/4.3/4.3/+download/Plone-4.3-UnifiedInstaller.tgz

5. Run the Plone installer as non-root-userd, standalone‚ mode.:

   .. code-block:: console

        # Extract the downloaded file
        tar -xf Plone-4.2.5-UnifiedInstaller.tgz
        # Go the folder containing installer script
        cd Plone-4.2.5-UnifiedInstaller
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

LibXML2/LibXSLT Versions
------------------------

If you are installing Plone 4.2+ or 4.1 with Diazo, you will need up-to-date versions of libxml2 and libxslt::

    LIBXML2 >= "2.7.8"
    LIBXSLT >= "1.1.26"

Ideally, install these via system packages or ports. If that's not possible,
use most current version of the z3c.recipe.staticlxml buildout recipe to build an lxml (Python wrapper) egg with static libxml2 and libxslt components.

Don't worry about this if you're using an installer.

Entering debug mode after installation
=========================================

When you have Plone installed and want to start
development you need do :doc:`enter debug mode </getstarted/debug_mode>`.

Installer source code
======================

* https://github.com/plone/Installers-UnifiedInstaller

================================================================
Installing old Plone 3.3 with Python 2.4
================================================================

.. admonition:: Description

   These are instructions for (re)installing old Plone 3.3 sites. These instructions
   are mainly useful if you need to get Plone 3.x series to run on a new server
   or on a local computer for maintance.

.. contents:: :local:

Introduction
================================

Due to the external changes introduced in Python ecosystem since the Plone 3.3
release a lot of things are broken if you are trying to reinstall
Plone using non-modified config files and tools.

Here is a list where you can update steps which are needed
to get old sites running again.

Plone 3.3 installation
======================

OS X Preparations
-----------------

Install Homebrew
~~~~~~~~~~~~~~~~

Needed to get Python 2.4 on OSX.

If you have not Apple's XCode installed, follow `Homebrew installation instructions <https://github.com/mxcl/homebrew/wiki/Installation>`_.

Run::

    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

Install Python 2.4
~~~~~~~~~~~~~~~~~~

Plone 3.x needs Python 2.4 explicitly.

Install it using Homebrew::

    /usr/local/bin/brew tap homebrew/versions
    /usr/local/bin/brew install python24

Now you have ``/usr/local/Cellar/python24/2.4.6/bin/python2.4`` command.

Linux
-----

You'll need the GNU build tools.
On Debian/Ubuntu packages, this is in a build-essentials metapackage.
On other platforms, install gcc, gmake, gpp, libjpeg-dev, libz-dev.

If you are operating on an older Linux platform, you may have Python 2.4 pre-installed or available as a package.
If so, use that.

On older systems (typically prior to 64-bit), there's a good chance that Plone's Unified Installer will work for you. Try it first.

On newer Linux systems, Python 2.4 may not be available as a package, and may not build simply from source.

If that's the case, install the git package and clone the collective buildout.python kit::

    git clone git://github.com/collective/buildout.python.git

Use that with your current Python to build a local Python-2.4.
The buildout.python kit deals with several problems of installing an old Python on a new platform.

Create site folder
------------------------------------------

Place the reinstallation site in a folder ``~/code/myplone3site`` (example).

    mkdir ~/code/myplone3site

Create Python virtualenv
------------------------------------------

This is needed in order to make sure something runs well with buildout, old setuptools
and old broken Python stuff in generally::

    cd ~/code/myplone3site
    curl -L -o virtualenv.py https://raw.github.com/pypa/virtualenv/1.7.2/virtualenv.py
    /usr/local/Cellar/python24/2.4.6/bin/python2.4 virtualenv.py --no-site-packages venv

We need to upgrade Python 2.4 installation to use latest Distribute (setuptools)::

    source venv/bin/activate
    easy_install -U Distribute

We also need Python imaging package and simplejson which are often used libraries::

    easy_install Pillow==1.7.8      # PY24 compatible
    easy_install simplejson==2.3.3  # PY24 compatible

.. note ::

    Old 1.7.2 virtualenv required as above. Latest versions are not Python 2.4 compatible.

Copy in sites files
------------------------------------------

This includes

* Buildout.cfg

* Data.fs

* Creating basic folder structure

Example::

    cd ~/code/myplone3site
    mkdir src
    mkdir eggs
    mkdir downloads
    mkdir var
    mkdir products
    mkdir var/filestorage
    cp .../xxx/buildout.cfg . # Copy in buildout config from somewhere
    cp .../xxx/Data.fs var/filestorage # Copy in database from somewhere

    # cp -r ../xxx/src .  # Copy custom source code products if your site have them

    # Note: You also need to copy "blobstorage" if your Plone 3.x
    # site was configured to use file-system backed filestorage
    # but this was not the default option

.. note ::

    If your buildout contains unpinned eggs you'll get version conflicts
    when running the buildout. Please see developer.plone.org Troubleshooting
    section how to solve these.

More info

* http://plone.org/documentation/kb/copying-a-plone-site

Rebootstrap buildout on your local computer
------------------------------------------

This creates buildout script and paths to conform your local computer folder structure.
We need to update Buildout's ``bootstrap.py``, since the release of Buildout 2.x have
broken the old installations. Also, we need to use a virtualenv'ed Python,
since old Buildout versions have a bug they incorrectly try to modify
system-wide Python installation files-

Enter ``~/code/myplone3site``.

Run::

    cd ~/code/myplone3site

    # Use Python interpreter from the virtualenv
    source venv/bin/activate

    # Download Plone 3.x compatible Buildout bootstrapper script
    curl -L -o bootstrap.py http://downloads.buildout.org/1/bootstrap.py

    # Creates bin/buildout
    python boostrap.py

More info

* http://stackoverflow.com/q/14817138/315168

Run buildout
------------------------------------------

This should fetch Plone 3.3 Python eggs from *plone.org* and *pypi.python.org*
and create ``bin/instance`` launch script for them using buildout::

    cd ~/code/myplone3site
    /usr/local/Cellar/python24/2.4.6/bin/python2.4 bootstrap.py
    bin/buildout

    # The followind step is only needed if your buildout.cfg
    # users Mr. Developer tool to manager source code repotories
    # ... also bin/buildout above does not complete on the first time
    # but bin/develop script gets created.
    # This command will checkout
    bin/develop co ""

    # Now you can run buildout and it should complete
    bin/buildout

If the network times out just keep hitting ``bin/buildout``
until it completes succesfully.

Start site
------------------------------------------

Try starting the site::

    bin/instance fg

Enter ``http://localhost:[SOMEPORT]`` with your browser as stated by
Zope start-up info.

Troubleshooting
================================================================

Asssertation error with SVN
------------------------------------------

When running bin/buildout.

Example::

    _info.py", line 233, in get_svn_revision
    IndexError: list index out of range

Make sure setuptools / distribute eggs being used is up-to-date.

Mr. Developer tries checkout packages too greedily
------------------------------------------------------------------------------------

Mr. Developer tries to auto checkout packages even if they are not
destined to do so. This causes buildout to run all kind of
shitty errors.

On your first virgin buildout run the following should not happen::

    INFO: Queued 'collective.batch' for checkout.
    INFO: Queued 'collective.eclipsescripts' for checkout.
    INFO: Queued 'collective.externalcontent' for checkout.
    INFO: Queued 'collective.fastview' for checkout.

But if it is happening add in buildout.cfg::

    [versions]
    mr.developer = 1.21

(Also you might need to nuke src/ folder in this point)

Re-run buildout.

Manually checkout packages with::

    bin/develop co ""

Bad eggs gets picked up
-------------------------

You see eggs of bad version in bad location in Python tracebacks::

      File "/Users/mikko/code/buildout-cache/eggs/setuptools-0.6c11-py2.4.egg/setuptools/command/egg_info.py", line 85, in finalize_options
      File "/Users/mikko/code/buildout-cache/eggs/setuptools-0.6c11-py2.4.egg/setuptools/command/egg_info.py", line 185, in tags
      File "/Users/mikko/code/buildout-cache/eg

setuptools-06c11 is old and buggy and breaks your buildout.

Make sure you don't have global buildout defaults file::

    rm ~/.buildout/default.cfg

Other troubleshooting
-------------------------

See and read the source code of

* https://github.com/miohtama/senorita.plonetool

Workaround UnicodeDecodeErrors
----------------------------------

Old sites may give you plenty of these::


    Module Products.CMFCore.ActionInformation, line 151, in getInfoData
    UnicodeDecodeError: <exceptions.UnicodeDecodeError instance at 0x10f87efc8

Make UTF-8 to Python default encoding::

    cd ~/code/myplone3site
    nano venv/lib/python2.4/site.py

Change line::

      encoding = "ascii" # Default value set by _PyUnicode_Init()

To::

      encoding = "utf-8" # Default value set by _PyUnicode_Init()

Example pindowns
-------------------

Here are collection of some Plone 3 version pindowns you might need to add into your custom buildout.cfg::


         [versions]
         # zope.app.catalog 3.6.0 requires zope.index 3.5.0
         # zope.index 3.5.0 requires 'ZODB3>=3.8.0b1'
         # This will conflict with the fake ZODB egg.
         zope.app.catalog = 3.5.2
         zope.component = 3.5.1
         plone.app.z3cform=0.4.2
         plone.recipe.zope2instance = 3.6
         zope.sendmail = 3.6.0
         Products.PluggableAuthService = 1.6.2
         plone.z3cform = 0.5.8
         five.intid=0.4.2
         plone.reload = 0.11
         Products.GenericSetup = 1.5.0

         #collective.dancing pindowns
         zope.location=3.7.0
         zope.schema=3.5.1
         #zope.sendmail=3.5.1
         #five.intid=0.3.0

         #plone.z3cform pindowns
         zope.proxy = 3.6.1
         transaction = 1.1.1
         zc.queue = 1.2.1
         zope.copy = 3.5.0

         # Other fixes
         zope.i18n = 3.8.0
         z3c.batching = 1.1.0

         #0.9.8> does not support python2.4 anymore
         cssutils=0.9.7

         #0.6 caused Plone startup to fail, maybe requires newer Plone
         betahaus.emaillogin=0.5

         #Newest stable release
         Products.TinyMCE=1.2.7

         #Has fix to imagewidget preview tag http://dev.plone.org/archetypes/changeset/12227
         #Before this pindown 1.5.15 was used
         Products.Archetypes=1.5.16


         #2.1.1 caused problem with missing site.hooks
         #2.1 causing problems with catalog http://dev.plone.org/ticket/11396
         archetypes.schemaextender=2.0.3

         #4.x tries to import from plone.app.blob which isn't in Plone 3. Pindown to the current version on the live site
         Products.SimpleAttachment=3.4

         collective.singing=0.6.14_1
         simplejson=2.3.3
