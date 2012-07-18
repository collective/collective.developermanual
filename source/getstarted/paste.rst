=========================================
 Bootstrapping Plone add-on development
=========================================

.. contents :: :local:

.. admonition:: Description

        templer.plone package provides product scaffolding code for Plone to
        bootstrap your add-on development.

Introduction
------------

Templer is a Python helper and package colllection providing code skeleton templates for Plone add-ons and themes
for bootstrapping your Plone customization add-on work.

.. note ::

  In the past this package was known as ZopeSkel. The same templates could be triggered
  using *paster* and *zopeskel* commands.

Further reading
================

`For more in-depth information visit Templer manual <http://templer-manual.readthedocs.org/en/latest/index.html>`_

Add-on creation and installation steps
--------------------------------------

There are three steps in your add-on creation and installation procedure

* Create add-on code skeleton using Templer as instructed below.
  If you are unsure answer *yes* to all questions.

* Make it's code available in buildout as described in the installation instructions below.
  Adding code to buildout must be done only once. After this you see your
  add-on's Python egg registered in ``bin/instance`` script when you open the file.

* After this Zope loads your add Python and ZCML code on every Zope restart
  with ``bin/instance`` command. Because manual Plone restarts may
  be time-consuming use `sauna.reload <http://pypi.python.org/pypi/sauna.reload/>`_ package to make it happen fast
  and automatically every time you change Python code.

* Your add-on might need to provide :doc:`GenericSetup profile </components/genericsetup>`
  which does site database modifies **every time you run Add-on installer your site setup**.
  GenericSetup profile is just a bunch of
  XML files are just database snippets written to database
  when the add-on installs. This is independent of register Python and ZCML code and GenericSetup XML can be updated
  without site restart.

All add-ons do not provide GenericSetup profile if they do not modify the site database
in any way e.g. they provide only new :doc:`views </views/browserviews>`.

Enabling templer command via buildout
---------------------------------------

Add to your ``buildout.cfg``::

    parts =
        ...
        templer

    # create templer command in bin/
    # with Plone templates
    [templer]
    unzip = true
    recipe = zc.recipe.egg
    dependent-scripts = true
    eggs =
        Paste
        templer.plone
        templer.plone.localcommands

The following templer packages are available

* `templer.plone and templer.plone.localcommands <http://pypi.python.org/pypi/templer.plone/>`_ for basic Plone add-ons.
  This includes Archetypes content types.

* **TODO: templer templates for themes**

* **TODO: templer templates for Dexterity**

* **TODO: templer templates for buildouts**

After rerunning buildout, buildout adds the ``bin/templer`` command.

Now you can use templates, through **templer** from buildout folder::

        bin/templer

Troubleshooting
=================

If you get any exceptions running this command see :doc:`troubleshooting </troubleshooting/exceptions>`.
If self-service help doesn't get you anywhere `file issues on Github <https://github.com/collective/templer.plone>`_.

Templer templates
---------------------------------

.. note ::

    This section is still under construction. New template packaegs are being released.

``bin/templer`` command will list the available templates.

Useful templates you should know about (there are others).

* ``archetypes``: Create :doc:`Archetypes </content/archetypes/index>` based content types

* ``plone``: Basic contentless Plone add-on. Good for form, view, etc. customizations.
  You can add portlets in this package.

Creating an add-on product skeleton
-----------------------------------

After you have followed the steps above to add Templer to your buildout,
you can create your first add-on.

.. note ::

    If you are unsure about questions answer **yes**.

Create Archetypes based content types package::

    # Run in buildout folder
    cd src
    ../bin/templer archetype yourcompany.productname


After this you need to include the newly created egg in your ``buildout.cfg``::

    eggs =
        yourcompany.productname

    develop =
        src/yourcompany.productname

Rerun buildout.

:doc:`Restart Plone in foreground mode </troubleshooting/basic>`. If your code files contain errors it usually fails in this point
with a :doc:`Python traceback </troubleshooting/exceptions>`.

Now you should see your add-on in *Add/remove add-ons* in *Site setup* after logging into your local Plone site as admin.

.. note ::

    If you are migrating from old ZopeSkel templates you need to remove ZopeSkel frmo buildout first.

`Get rid of old ZopeSkel before starting using Templer <https://github.com/collective/templer.plone/blob/master/README.txt>`_.

Local commands
---------------------------------

Besides project templates, Templer package provides local commands.
Local commands are context aware commands to add more functionality to an existing Templer generated
project.

Examples of the kind of Plone functionality you can add with local commands

* Content types inside your add-on

* Portlets inside your add-on

* etc.


.. note ::

    Local commands are not available until your egg is correctly
    registered as development egg in buildout (this causes setup.py develop command
    run, creating necessary Paster hooks).

Creating a content type
===========================

In this example we will continue ``yourcompany.productname``
development and add our first Archetypes based content type.

Example of creating a content type::

        # First create an add-on skeleton if one does not exist
        cd src/yourcompany.productname/src

.. note ::

    You must enter *src* folder **inside** your package. Otherwise paster add command does not work.

To list available local commands templates type::

    ../../../bin/paster add -a

Now you can use ``paster`` ``addcontent`` local command to contribute to the existing project

Example of how to create a special content type for managing lectures::

        ../../../bin/paster add contenttype

.. note ::

    New content types come available through add-on product reinstall.
    You need to restart Plone **and** reinstall the add-on after creating a new content type.

In-depth background information
---------------------------------

How paster local commands work
================================

paster reads ``setup.py``. If it finds a *paster_plugins* section there,
it will look for local commands there.
For example, Plone project templates declare the following paste_plugins in setup.py::

        paster_plugins = ["Templer"]

:doc:`More about paster templates </misc/paster_templates>`.

setup.py install_requires
================================

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

