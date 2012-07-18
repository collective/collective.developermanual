=======================
Additional information
=======================

.. admonition:: Description

   Further in-depth information about dealing with buildout
   in Plone context

.. contents:: :local:

Recipes
--------

Buildout consists of recipes. A recipe consists of

* Python package distributed in pypi.python.org

* Declaration in [buildout] parts=partname

* [partname] section with recipe= telling the pypi.python.org name

Recipes are automatically downloaded from pypi as Python eggs.

Making buildout faster
------------------------

``easy_install`` craws unnecessary web pages when trying to install Python eggs.
You can limit this craw by having an allow-hosts whitelist::

    allow-hosts =
        github.com
        *.python.org
        *.plone.org
        *.zope.org
        launchpad.net

Buildout folder structure
--------------------------

Plone buildout's have folders which have predefined purposes

* ``bin/`` - add Python scripts and shell scripts installed by various eggs. Also ``buildout`` command itself.
  The default Plone start script ``bin/instance`` is here.

* ``parts/`` - constructed the source tree. This is wiped between buildout runs. You should not store
  any persistent information here (note: some broken recipes store things like pid files here). Generated
  configuration files are stored here and usually it is no help to change them,

* ``src/`` source code you are developing yourself

* ``eggs/`` extracted Python eggs

* ``downloads/`` Python egg download cache (may be elsewhere depending on the system config)

* ``var/`` database like data. Zope's Data.fs,

* ``bootstrap.py`` - installs buildout command

* ``buildout.cfg`` - basic buildout file. May extend other .cfg files. Sometimes there are many files
  and you need to pick one for buildout command. E.g.::

        bin/buildout -c production.cfg

Running buildout on Windows
-----------------------------

Windows Plone installer supplies ``buildout.exe``.
This executable uses system Python installation.
This installation is not necessary the correct Python
version if multiple Pythons are installed on the computer.

A lot of Windows Python software use
wrapper .exe files which pick the Python interpreter
based on this registry settings. One notable exe is buildout.exe,
which is used to run buildout.

If you install multiple Pythons,
the latter installations might not become active in the registry automatically,
and your Python wrapper still rely on the old version. This leads to
version incompatibilities and you are unable to start the Python applications.

Since only one Python interpreter can be activate at a time,
it is little bit difficult to develop multi-version Python code Windows.
This kind of situation could be that you develop Plone 3 sites
(Python 2.4) and Plone 4 sites (Python 2.6) simultaneously.

Below is regpy.py code which changes the active Python interpreter.
The orignal author is unknown, I picked up this code from some paste board
long time ago. Just run this code with your Python and the running
interpreter becomes active.

Example::

        C:\Plone\python\python.exe regpy.py

Code::

        import sys

        from _winreg import *

        # tweak as necessary
        version = sys.version[:3]
        installpath = sys.prefix

        regpath = "SOFTWARE\\Python\\Pythoncore\\%s\\" % (version)
        installkey = "InstallPath"
        pythonkey = "PythonPath"
        pythonpath = "%s;%s\\Lib\\;%s\\DLLs\\" % (
            installpath, installpath, installpath
        )

        def RegisterPy():
            try:
                reg = OpenKey(HKEY_LOCAL_MACHINE, regpath)
            except EnvironmentError:
                try:
                    reg = CreateKey(HKEY_LOCAL_MACHINE, regpath)
                    SetValue(reg, installkey, REG_SZ, installpath)
                    SetValue(reg, pythonkey, REG_SZ, pythonpath)
                    CloseKey(reg)
                except:
                    print "*** Unable to register!"
                    return
                print "--- Python", version, "is now registered!"
                return
            if (QueryValue(reg, installkey) == installpath and
                QueryValue(reg, pythonkey) == pythonpath):
                CloseKey(reg)
                print "=== Python", version, "is already registered!"
                return
            CloseKey(reg)
            print "*** Unable to register!"
            print "*** You probably have another Python installation!"

        if __name__ == "__main__":
            RegisterPy()

Example error when going from Plone 3 to Plone 4::

        Traceback (most recent call last):

          File "C:\xxx\bin\idelauncher.py", line 99, in ?

            exec(data, globals())

          File "<string>", line 419, in ?

          File "c:\xxx\buildout-cache\eggs\plone.recipe.zope2instance-4.0.3-py2.6.egg\plone\recipe\zope2instance\__init__.py", line 27, in ?

            from plone.recipe.zope2instance import make

          File "c:\xxx\buildout-cache\eggs\plone.recipe.zope2instance-4.0.3-py2.6.egg\plone\recipe\zope2instance\make.py", line 5, in ?

            from hashlib import sha1

        ImportError: No module named hashlib

More info

* http://blog.mfabrik.com/2011/02/22/changing-the-active-python-interpreter-on-windows/

Running buildout behind proxy
------------------------------

Buildout uses setuptools which uses urllib which allows you to set
proxy using http_proxy (lowecase!) environment variable.

Example for UNIX shell (bash)

::

        # Set proxy address as environment varoable.
        # In this case we use Polipo server running on the same compuer.
        http_proxy=http://localhost:8123/

        # This is Bash shell specific command to export environment variable
        # to processes started from the shell
        export http_proxy

        # Run buildout normally
        bin/buildout

You can also SSH tunnel the proxy from a remote server::

        # Make Polipo proxy yourserver.com:8123
        # made to be available at local port 8123
        # through SSH tunnel
        ssh -L 8123:localhost:8123 yourserver.com

Buildout cache folder
----------------------

If you are running several buildouts on the same user you should
consider setting the cache folder. All downloaded eggs are cached here.

There are two ways to set the cache folder

* PYTHON_EGG_CACHE environment variable

* download-cache variable in [buildout] - only recommended if the buildout.cfg
  file is not shared between different configurations

Example::

        # Create a cache directory
        mkdir ~/python-egg-cache

        # Set buildout cache directory for this shell session
        export PYTHON_EGG_CACHE=~/python-egg-cache

Buildout defaults
=================

You can set user wide buildout settings in the following file::

        $HOME/.buildout/default.cfg

This is especially useful if you are running many Plone development buildouts on your computer
and you want them to share the same buildout egg cache settings.


Manually picking downloaded and active component versions
----------------------------------------------------------

This is also known as pindowning. You can manually choose what Python egg versions
of each component are used. This is often needed to resolve version conflict issues.

* http://www.uwosh.edu/ploneprojects/documentation/how-tos/how-to-use-buildout-to-pin-product-versions

Migrating buildout to different Python interpreter
---------------------------------------------------

You are either

* Copying the whole buildout folder to a new computer (not recommended)

* Changing Python interpreter on the same computer

First you need to clear existing eggs as they might contain binary compilations
for wrong Python version or CPU architecture

.. code-block:: console

        rm -rf eggs/*

Clear also src/ folder if you are developing any binary eggs.

Buildout can be made aware of new Python interpreter by rerunning bootstrap.py.

.. code-block:: console

        source ~/code/python/python-2.4/bin/activate
        python bootstrap.py

Then run buildout again and it will fetch all Python eggs for the new Python interpreter

.. code-block:: console

        bin/buildout

Setting up Plone site from buildout.cfg and Data.fs
---------------------------------------------------

This is often needed when you are copying or moving Plone site.
If repeatable deployment strategy is done right, everything
needed to establish a Plone site is

* buildout.cfg which described Plone site and its add-on products and how they are downloaded or checked out from version control

* Data.fs which contains the site database

Below is an example process.

Activate Python 2.6 for Plone (see :doc:`how to use virtualenv controlled non-system wide Python </getstarted/python>`)::

        source ~/code/python/python-2.6/bin/activate

Install ZopeSkel templates which contains a buildout and folder structure template for Plone site (plone3_buildout
works also for Plone 4 as long as you type in the correct version when paster template engine asks for it)::

        easy_install ZopeSkel # creates paster command under virtual bin/ folder and downloads Plone/Zope templates
        paster create -t plone3_buildout


        paster create -t plone3_buildout newprojectfoldername
        ...
        Selected and implied templates:
          ZopeSkel#plone3_buildout  A buildout for Plone 3 installation
        ...

        Expert Mode? (What question mode would you like? (easy/expert/all)?) ['easy']:
        Plone Version (Plone version # to install) ['3.3.4']: 4.0
        Zope2 Install Path (Path to Zope2 installation; leave blank to fetch one!) ['']:
        Plone Products Directory (Path to Plone products; leave blank to fetch [Plone 3.0/3.1 only]) ['']:
        Initial Zope Username (Username for Zope root admin user) ['admin']: admin
        Initial User Password (Password for Zope root admin user) ['']: admin
        HTTP Port (Port that Zope will use for serving HTTP) ['8080']:
        Debug Mode (Should debug mode be "on" or "off"?) ['off']: on
        Verbose Security? (Should verbose security be "on" or "off"?) ['off']: on

Then you can add copy buildout.cfg from the existing site to your new project ::

        copy buildout.cfg newproject # Copy the existing site configuration file to new project
        cd newproject
        python bootstrap.py # Creates bin/buildout command for buildout
        bin/buildout # Run buildout - will download and install necessary add-ons to run Plone site

Assuming buildout completes succesfully, test that the site starts (without database)::

        bin/instance fg # Start Zope in foreground debug mode

Press CTRL+C to stop the instance.

Now copy the existing database Data.fs to buildout::

        cp Data.fs var/filestorage/Data.fs # There should be existing Data.fs file here, created by site test launch

If you do not know the admin user account for the database, you can create additional admin user::

        bin/instance adduser admin2 admin # create user admin2 with password admin

Check Zope start up message in which port the instance is running (default port is 8080)::


        2010-09-06 12:55:17 INFO ZServer HTTP server started at Mon Sep  6 12:55:17 2010
        Hostname: 0.0.0.0
        Port: 20001

Then log in to Zope Management Interface by going with your browser::

        http://localhost:8080

.. _configuring-products-from-buildout:

Configuring plone products from buildout
----------------------------------------

You can configure add-on products with the zope-conf-additional section of the plone.recipe.zope2instance part::

        [instance]
        recipe = plone.recipe.zope2instance
        ...
        zope-conf-additional =
        <product-config foobar>
            spam eggs
        </product-config>

This adds the configuration sections to your zope.conf file.

Any named product-config section is then available as a simple dictionary to any python product that cares to look for it.
The above example creates a 'foobar' entry which is a dict with a 'spam': 'eggs' mapping.

Here is how you then access that from your code::

        from App.config import getConfiguration

        config = getConfiguration()
        configuration = config.product_config.get('foobar', dict())
        spamvalue = configuration.get('spam')

A similar method is used to configure the built-in Zope ClockServer enabling you to trigger scripts::

        zope-conf-additional =
            <clock-server>
                method /mysite/do_stuff
                period 60
                user admin
                password secret
                host www.mysite.com
            </clock-server>


Setting LD_LIBRARY_PATH
-------------------------

``LD_LIBRARY_PATH`` is UNIX environment variable tell from which folders load native dynamic linked libraries (.so files).
You might want to override your system-wide libraries, because operating systems may ship with old, incompatible, versions.

You can use ``environment-vars`` of `zope2instance <http://pypi.python.org/pypi/plone.recipe.zope2instance>`_ recipe.

Example in buildout.cfg

.. code-block:: cfg

        [instance]
        # Use statically compiled libxml2
        environment-vars =
                LD_LIBRARY_PATH ${buildout:directory}/parts/lxml/libxml2/lib:${buildout:directory}/parts/lxml/libxslt/lib

Paste factory
--------------

Web based user interface to create different buildouts

* http://pypi.python.org/pypi/collective.generic.webbuilder

Troubleshooting
----------------

See :doc:`Buildout troubleshooting </troubleshooting/buildout>` chapter.
