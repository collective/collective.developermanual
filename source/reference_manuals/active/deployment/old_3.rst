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

Plone 3.3 installation on OSX
================================

Install Homebrew
--------------------

Needed to get Python 2.4 on OSX.

If you have not Apple's XCode installed, follow `Homebrew installation instructions <https://github.com/mxcl/homebrew/wiki/Installation>`_.

Run::

    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

Install Python 2.4
---------------------

Plone 3.x needs Python 2.4 explicitly.

Install it using Homebrew::

    /usr/local/bin/brew tap homebrew/versions
    /usr/local/bin/brew install python24

Now you have ``/usr/local/Cellar/python24/2.4.6/bin/python2.4`` command.

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
