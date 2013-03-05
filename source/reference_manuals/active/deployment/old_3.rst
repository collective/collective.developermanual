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