====================
 Zopeskel templates
====================

.. contents :: :local:

.. admonition:: Description

        ZopeSkel / paster template package provides product scaffolding code for Plone to
        start programming Plone more easily.

Introduction
------------

ZopeSkel is a Python packake providing code skeleton templates for Plone add-ons and themes
for bootstrapping your Plone customization add-on work.

More about ZopeSkel

* http://plone.org/products/zopeskel

Add-on creation and installation steps
--------------------------------------

There are three steps in your add-on creation and installation procedure

* Create add-on code skeleton using ZopeSkel as instructed below.
  If you are unsure answer *yes* to all questions.

* Make it's code available in buildout as described in the installation instructions below.
  Adding code to buildout must be done only once. After this you see your 
  add-on's Python egg registered in ``bin/instance`` script when you open the file.

* After this Zope loads your add Python and ZCML code on every Zope restart
  with ``bin/instance`` command.

* Your add-on might need to provide :doc:`GenericSetup profile </components/genericsetup>`
  which does site database modifies **every time you run Add-on installer your site setup**.
  GenericSetup profile is just a bunch of 
  XML files are just database snippets written to database
  when the add-on installs. This is independent of register Python and ZCML code and GenericSetup XML can be updated
  without site restart.

All add-ons do not provide GenericSetup profile if they do not modify the site database
in any way e.g. they provide only new :doc:`views </views/browserviews>`.

Zopeskel and buildout
----------------------

If you are using buildout to manage your Python application deployment, you can integrate zopeskel/paster
with it.

The basic template package is ``ZopeSkel`` which depends on ``Paster``. ``zopeskel.dexterity`` adds
support for Dexterity content types.

Add to your *buildout.cfg*::


        parts =
            ...
            zopeskel
            paster


        [zopeskel]
        recipe = zc.recipe.egg
        eggs =
                ZopeSkel<2.99
                zopeskel.dexterity
                ${instance:eggs}

        [paster]
        recipe = zc.recipe.egg
        eggs =
                PasteScript
                ZopeSkel<2.99
                zopeskel.dexterity
                ${instance:eggs}



After rerunning buildout, buildout adds the *paster* command to the *bin* folder.

Then you can use ZopeSkel templates, through **paster** from buildout folder::

        bin/paster

.. note ::
    
    This recipe will provide you with a **zopeskel** script under
    bin folder. This script is a safer wrapper around paster, but
    providing less features


.. warning ::

    It is recommended to install and use the paster from the virtualenv for your instance and not from your system Python.
    This way paster is aware of your deployment configuration and local commands
    won't explode in your face.

Creating an add-on product skeleton
-----------------------------------

After you have followed the steps above to add ZopeSkel to your buildout,
you can create your first add-on.

Create theme (applies for Plone 4 also)::

	bin/paster create -t plone3_theme plonetheme.mythemeid

Create Archetypes based content types package::

	bin/paster create -t archetype mycompanyid.content

Create other Plone customizations::

	bin/paster create -t plone mycompanyid.mypackageid

Some questions are asked to fill in version information, etc.
When ``plone`` template asks for *GenericSetup profile* answer ***yes**.

After this you need to include the newly created egg in your buildout.cfg::

	eggs =
		yourcompany.productname

	develop =
		src/yourcompany.productname

Rerun buildout.

Restart Plone in foreground mode. If your template input contained errors it usually fails in this point.

Now you should see your add-on in the Plone add-on installer.

Base ZopeSkel templates
---------------------------------

The basic templates provided by ZopeSkel are:

+-----------------------------------------------------------------------------+
| Plone Development                                                           |
+===================+=========================================================+
|  archetype        | A Plone project that uses Archetypes content types      |
+-------------------+---------------------------------------------------------+
|  kss_plugin       | A project for a KSS plugin                              |
+-------------------+---------------------------------------------------------+
|  plone            | A project for Plone add-ons                             |
+-------------------+---------------------------------------------------------+
|  plone3_portlet   | A Plone 3 portlet                                       |
+-------------------+---------------------------------------------------------+
|  plone_app        | A project for Plone add-ons with a nested namespace     |
|                   | (2 dots in name)                                        |
+-------------------+---------------------------------------------------------+
|  plone_pas        | A project for a Plone PAS plugin                        |
+-------------------+---------------------------------------------------------+

+-----------------------------------------------------------------------------+
| Plone Theme Development                                                     |
+===================+=========================================================+
|  plone2_theme     | A theme for Plone 2.1                                   |
+-------------------+---------------------------------------------------------+
|  plone2.5_theme   | A theme for Plone 2.5                                   |
+-------------------+---------------------------------------------------------+
|  plone3_theme     | A theme for Plone 3                                     |
+-------------------+---------------------------------------------------------+

+-----------------------------------------------------------------------------+
| Buildout                                                                    |
+===================+=========================================================+
| plone2.5_buildout | A buildout for Plone 2.5 projects                       |
+-------------------+---------------------------------------------------------+
| plone3_buildout   | A buildout for Plone 3 installation                     |
+-------------------+---------------------------------------------------------+
| plone4_buildout   | A buildout for Plone 4 installation                     |
+-------------------+---------------------------------------------------------+
| plone_hosting     | Plone hosting: buildout with ZEO and Plone versions     |
|                   | below 3.2                                               |
+-------------------+---------------------------------------------------------+
| recipe            | A recipe project for zc.buildout                        |
+-------------------+---------------------------------------------------------+
| silva_buildout    | A buildout for Silva projects                           |
+-------------------+---------------------------------------------------------+

+-----------------------------------------------------------------------------+
| Python Development                                                          |
+===================+=========================================================+
|  basic_namespace  | A basic Python project with a namespace package         |
+-------------------+---------------------------------------------------------+
|  basic_package    | A basic setuptools-enabled package                      |
+-------------------+---------------------------------------------------------+
|  nested_namespace | A basic Python project with a nested namespace          |
|                   | (2 dots in name)                                        |
+-------------------+---------------------------------------------------------+

+-----------------------------------------------------------------------------+
| Zope Development                                                            |
+===================+=========================================================+
|  basic_zope       |  Zope project                                           |
+-------------------+---------------------------------------------------------+

To list all templates available in your paster installation you can execute
the script with the *--list-templates* switch::

    ./bin/paster create --list-templates



Local commands
---------------------------------

Besides generic project templates, ZopeSkel package provides local commands.
Local commands are context aware commands to add more functionality to an existing ZopeSkel generated
project.

Examples of the kind of Plone functionality you can add with local commands

* Views

* Content types

* Forms

* Portlets

Example
=======

In this example we will create an Archetypes based content type add-on product.
We will first create the project skeleton, then enter the project
and add more content types there using local commands.

Example of creating a content type::

		# First create an add-on skeleton if one does not exist
        cd src
        ../bin/paster create -t archetype mycompanyid.mycustomcontenttypes

        # Now new paster commands are available and listed when paster is run in this folder
        cd mycompanyid.mycustomcontenttypes
        ../../bin/paster

        Usage: ../../bin/paster COMMAND
        usage: paster [paster_options] COMMAND [command_options]

        ...

        Commands:
          ...

        ZopeSkel local commands:
          addcontent   Adds plone content types to your project


Above, ZopeSkel paster template adds its addcontent templates.
Now you can use ``addcontent`` local command to contribute to the existing project

Example of how to create a special content type for managing lectures::

        ../../bin/paster addcontent contenttype LectureInfo

Then you can add new fields to that content type::

        ../../bin/paster addcontent atschema

.. note ::

    If you prefer a special order of the fields, add them in reverse order.

.. note ::

	When changing the add-on code the changes usually touch GenericSetup XML files (ones
	in profiles/default folder). These changes are not reflected in Plone/Zope application
	server when it is restarted, because they are site specific changes and apply to one
	site only. You need to rerun the add-on product installer when these files have changed.

Dexterity templates
---------------------------------

By default, ZopeSkel generates code for old :doc:`Archetypes content subsystem </content/archetypes/index>`.
From  Plone 4.1+ onward you might want to use more lean :doc:`Dexterity subsystem </content/dexterity>`.

* `Install Dexterity templates for ZopeSkel <http://pypi.python.org/pypi/zopeskel.dexterity>`_.
 

In-depth background information
---------------------------------

How paster local commands work
================================

paster reads ``setup.py``. If it finds a *paster_plugins* section there,
it will look for local commands there.
For example, Plone project templates declare the following paste_plugins in setup.py::

        paster_plugins = ["ZopeSkel"]

For more about paster templates, see :doc:`/misc/paster_templates`.

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

