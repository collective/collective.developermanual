=========================================
 Bootstrapping Plone add-on development
=========================================

.. contents :: :local:

.. admonition:: Description

        ZopeSkel is a tool that helps you to rapidly generate skeleton code useful in development for Plone.

Introduction
------------

ZopeSkel provides a command-line utility and a number of templates that help you to generate skeleton code 
for a Plone project.  Using ZopeSkl you can create Plone buildouts, add-on packages and themes.  The skeleton
code created by ZopeSkel follows generally accepted best practices, and will get you started developing for 
the Plone CMS.

.. note ::

  In the past, ZopeSkel was a single, large package.  It has been broken into a number of smaller packages to 
  help make it more flexible and easy to work with.  These packages are in the templer namespace (templer.core,
  templer.plone, etc.)  If you are interested in Plone development, you should simply install ZopeSkel.  
  It will include everything you need.

Further reading
================

`For more in-depth information about the templer system which underlies ZopeSkel, visit the Templer Manual 
<http://templer-manual.readthedocs.org/en/latest/index.html>`_

Add-on creation and installation steps
--------------------------------------

There are three steps in your add-on creation and installation procedure

* Create add-on code skeleton using ZopeSkel as instructed below. The tool will provide sensible 
  defaults for all options, so if you unsure about an answer, simple accept the default.

* Make your new add-on available in buildout as described in the installation instructions below.
  Adding code to buildout is done only once. After this you can see your package listed in the 
  ``bin/instance`` script when you open the file.

* After this Zope will load your Python and ZCML code every time Zope is restarted with the 
  ``bin/instance`` command. Because manual restarts can be time-consuming you may use the
  `sauna.reload <http://pypi.python.org/pypi/sauna.reload/>`_ package to make it happen fast
  and automatically every time you change Python code in your package.

If you want your add-on to be 'activated' by going to the Plone Add-on control panel, you will
need to have a :doc:`GenericSetup profile </components/genericsetup>`.  ZopeSkel can set
this up for you, just say 'Yes' if you are asked.  Some templates require a profile, and will not ask.
This profile modifies the site database **every time you run Add-on installer your site setup**.  
If you make changes to your profile, you need to **re-run the installation of your package** to pick
up those changes.

A GenericSetup profile is just a bunch of XML files with information that is written to the database
when the add-on is installed. This is independent of Python and ZCML code and GenericSetup XML can be 
updated without restarting the site.

All add-ons do not provide GenericSetup profile.  If an add-on does not modify the site database
in any way e.g. they provide only new :doc:`views </views/browserviews>`, it may not require one. But
a GenericSetup profile is required in order to have the add-on appear in the list of 'available add-ons'
in the Plone Add-ons control panel.

Adding ZopeSkel to your buildout
--------------------------------

To install ZopeSkel in your buildout, add the following to your ``buildout.cfg`` in the appropriate places::

    # add a 'zopeskel' part to the list of parts in the [buildout] section.
    parts =
        ...
        zopeskel

    # create zopeskel command in bin/
    # with Plone templates
    [zopeskel]
    recipe = zc.recipe.egg
    unzip = true
    eggs =
        Paste
        ZopeSkel

After adding this, run buildout and it will install ZopeSkel and all the templer and Paste packages
that it requires. After buildout completes, you will find the ``zopeskel`` command in the ``bin`` 
directory of your buildout.  You can use this command to list template, run them, and build the
skeleton code you need to get started.

To find out what templates are available, run::

    bin/zopeskel --list

To get extensive documentation on the abilities of ZopeSkel, run::

    bin/zopeskel --help

Troubleshooting
=================

If you get any exceptions running this command see :doc:`troubleshooting </troubleshooting/exceptions>`.
If self-service help doesn't get you anywhere `file issues on Github 
<https://github.com/collective/ZopeSkel/issues>`_.

.. note ::

    If you are migrating from a version of ZopeSkel prior to 3.0, you may need to remove the old ZopeSkel
    egg before you begin.  You can find notes about this in the README for `templer.plone 
    <https://github.com/collective/templer.plone/blob/master/README.txt>`_.

ZopeSkel Templates
------------------

.. note ::

    The templates listed below may not be the only ones available when you install ZopeSkel.  New
    templates are being developed actively.

* ``archetypes``: Creates a package skeleton for :doc: `Archetypes </content/archetypes/index>` 
  based content types.  

* ``plone_basic``: Creates a basic skeleton good for general Plone add-on packages.  Minimal and 
  clean.  You can use this package to set up views, forms, portlets, and many other add-on features.

* ``plone_nested``: Creates a nested namespace package with the same basic skeleton as 
  ``plone_basic``.  This is generally used for packages that are meant to be part of a set, like
  ``collective.blog.feeds``, ``collective.formwidget.autocomplete`` or ``collective.geo.mapwidget``.

Creating an add-on product skeleton
-----------------------------------

After you have followed the steps above to add ZopeSkel to your buildout,
you can create your first add-on::

.. note ::

    If you are unsure about questions, you may type ``?`` to get more information.  You can also
    just hit enter to accept the default value.  These are sensible for most cases.

To create an Archetypes based content types package::

    # Actual location is your Plone installation
    # Usually the folder name is zintance or  zeocluster 
    cd /path/to/buildout 
    cd src
    ../bin/templer archetype yourcompany.productname

After answering the questions, you'll have a new python package in the ``src`` directory of your 
buildout.  To begin using this code, you'll need to include the newly created package in your 
``buildout.cfg``::

    eggs =
        yourcompany.productname

    develop =
        src/yourcompany.productname

Rerun buildout to pick up the new package.

:doc:`Restart Plone in foreground mode </troubleshooting/basic>`. If your new code files contain errors 
it usually fails in this point with a :doc:`Python traceback </troubleshooting/exceptions>`.  This 
traceback will contain valuable information about what went wrong, and will be the first thing anyone
will ask for if you seek help.

Once Plone has started, log in as admin and go to ``Site Setup`` > ``Add-ons``.  If your package has
a GenericSetup profile, you should see your add-on in the list of ``available`` add-ons at the top of 
the page.

Local commands
--------------

Besides project templates, ZopeSkel allows templates to define **local commands**.
Local commands are context aware commands that allow you to add more functionality
to an existing project generated by ZopeSkel.

Examples of the kind of Plone functionality you can add with local commands

* Content types inside your add-on. 
* Schemas for your content types.
* Browser views
* Browser layers (to allow you to isolate add-on code to sites where your package is activated)

* etc.


.. note ::

    Local commands are not available until your egg is registered as development egg 
    in your buildout. This causes python to execute code which creates the required
    Paster hooks.  If you follow the instructions below and do not see an ``add`` local
    command, please verify that your package has been properly added to your buildout
    and that buildout has been re-run afterwards.

Adding a Content Type to your package
=====================================

In this example we will continue ``yourcompany.productname`` development and add our first 
Archetypes based content type.

Example of creating a content type::

        # First create an add-on skeleton if one does not exist
        cd yourcompany.productname/src

.. note ::

    You must enter *src* folder **inside** your package. Otherwise the paster add command cannot
    work.

To list the local commands available to your package, type::

    ../../../bin/paster add --list

This will display local commands that will work for the package you have created.  Different
package types have different local commands.  Next you can use the ``paster`` ``add`` local 
command to add new functionality to your existing code.

For example, to add a special content type for managing lectures::

    ../../../bin/paster add at_contenttype

After the content type is added, you can add schema fields for the type::

    ../../../bin/paster add at_schema_field

.. note ::

    New content types are added to Plone using GenericSetup.  GenericSetup profiles are run
    when an add-on product is **activated**.  To see the content type you create, you'll need 
    to restart Plone **and** reinstall the add-on.

In-depth background information
---------------------------------

How paster local commands work
================================

Paster reads ``setup.py``. If it finds a *paster_plugins* section there, it will look for 
local commands. For example, the Archetype template declares the following paster_plugins 
in setup.py::

        paster_plugins=["templer.localcommands"],

This allows paster to know that packages created by that template provide local commands
defined by the templer system which underlies ZopeSkel.

:doc:`More about paster templates </misc/paster_templates>`.

setup.py install_requires
=========================

Python modules can specify dependencies to other modules by using the *install_requires* setup.py section. For example, a Plone add-on might read::

      install_requires=['setuptools',
                        # -*- Extra requirements: -*-
                        "five.grok",
                        "plone.directives.form"
                        ],

This means that when you use setuptools/buildout/pip/whatever Python package
installation tool to install your package from `Python Package Index (PyPi) <http://pypi.python.org/pypi>`_
it will also automatically install Python packages declared in install_requires.

paster and install_requires
===========================

.. warning ::

    Never use a system-wide paster installation with local
    commands. This is where things usually go haywire. Paster is not
    aware of this external Python package configuration set (paster
    cannot see them in its PYTHONPATH). Also don't try to execute
    system-wide ``paster`` in a Python source code
    folder containing ``setup.py``. Otherwise paster downloads all the
    dependencies mentioned in the ``setup.py`` into that folder even
    though they would be available in the ``eggs`` folder (which
    paster is not aware of).

