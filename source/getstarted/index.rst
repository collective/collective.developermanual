==================
Getting started
==================

How to get started with Plone development.

.. contents:: :local:

Introduction
--------------

Plone is developed in the :doc:`Python </getstarted/python>` programming language. You should master Python basics
before you can efficiently customize Plone. If you are very new to Python, Plone or software development, 
it is suggested that you read the `Professional Plone 4 Development book 
<http://www.packtpub.com/professional-plone-4-development/book>`_
before you attempt to develop your own solutions.

Plone runs on the top of the `Zope 2 application server <zope2.zope.org/>`_ meaning that one Zope 2 server process
can contain and host several Plone sites. Plone also uses Zope 3 components. Zope 3 is not an upgrade for Zope 2,
but a separate project.

Internally, Plone uses the objected-oriented :doc:`ZODB </persistency/index>` database and the development
mindset greatly differs from that of SQL based systems. SQL backends can still be integrated to Plone,
like for any other Python application, but this is a more advanced topic.

Installing Plone
------------------

It is recommended that you do Plone development on Linux or OS X. Development on Windows is possible,
but you need to have much more experience dealing with Python and Windows related problems, so starting 
on Windows is not so easy.

See :doc:`installation instructions </getstarted/installation>` for how to create a Plone installation 
suitable for development.

Non-programming approaches for customizing Plone
-------------------------------------------------

If you lack programming skill or resources you can still get somet things done in Plone

* `Plomino is a a powerful and flexible web-based application builder for Plone <http://www.plomino.net>`_

* `PloneFormGen allows you to build forms in a web browser <http://plone.org/products/ploneformgen>`_ 

* Plone 4+ comes with through-the-web Dexterity content type editor

However, for heavy customization Python, Javascript, TAL page template and CSS programming is needed, 
as explained above.

Enabling debug mode
--------------------

By default, Plone runs in a *production mode* where changed files in the file system
are not reflected in the served HTML. When you start developing Plone you need to
first :doc:`put it into a debug mode </getstarted/debug_mode>`.

Plone add-ons as Python packages
-----------------------------------

Plone sites can be customized by installing *Plone add-ons*, which add or customize functionality.
You can install existing add-ons that others have developed or you can develop and install your own add-ons.
Add-ons are developed and distributed as 
`Python packages <http://packages.python.org/distribute/setuptools.html>`_. Many open-source Python packages, 
including Plone add-ons, are available from `PyPI (the Python Package index) <http://pypi.python.org>`_.

Plone uses a tool called `Buildout <http://www.buildout.org/>`_ to manage the set of Python packages 
that are part of your Plone installation.
Using Buildout involves using the :doc:`buildout.cfg` configuration file and the :doc:`bin/buildout` command.

.. note ::

  In prior versions of Plone and Zope, add-ons were referred to as "products" and they were installed by copying
  them into a special folder called :doc:`products`. This method is now deprecated in favor of using 
  standard Python packages, managed by Buildout.


Creating your first add-on
----------------------------

Since Python egg package structure is little bit complex, to get started with your first add-on
you can create a code skeleton (scaffold) for it using :doc:`Plone ZopeSkel code templates </getstarted/paste>`.

* ZopeSkel generates a basic Python egg package with some Plone files in-place.

* This package is registered to buildout as a development egg in the ``buildout.cfg`` file.

* Buildout is rerun which regenerates your ``bin/instance`` script with the new set of Python eggs.

* You start your Plone instance in debug mode.

* You install your add-on through ``Add/remove add-ons``

.. note ::

  There are different scaffolds for different kind of add-ons. The most typically used are ``plone3_theme``,
  ``archetype`` (create Archetypes content), ``dexterity`` (create Dexterity content) and ``plone``
  (barebone Plone add-on).

Please read how to use :doc:`ZopeSkel to bootstrap your first add-on </getstarted/paste>`.

If you want to create a package with :doc:`Dexterity content types please read the tutorial</getstarted/dexterity>`.

Plone development workflow
----------------------------

You never edit Plone files directly. Everything under ``parts`` and ``eggs``
folders in your Plone installation is downloaded from the internet and dynamically generated,
based on ``buildout.cfg``. Plone is free to override these files on any update.

You need to have your own add-on in the ``src/`` folder as created above.
There you overlay changes to the existing Plone core through extension mechanisms provided by Plone:

* :doc:`Layers </views/layers>`

* :doc:`Adapters </components/adapters>`

* :doc:`Installation profiles </components/genericsetup>`

Plone development always happens on your local computer or the development server.
The changes are moved to production through version control system like Git or Subversion.

**The best practice is that you install Plone on your local computer for development**.

Plone add-on features
-----------------------

Plone add-ons usually:

* Create custom :doc:`content types </content/index>` or extend existing ones for your specialized need. Plone has
  two subsystems for content types: :doc:`Dexterity (new) </content/dexterity>` and :doc:`Archetypes (old) </content/archetypes/index>`.

* Add new :doc:`views </views/browserviews>` for your site and its content.

* Create Python-processed :doc:`forms </forms/index>` on your site.

* Theme your site

* etc.

A lot of Plone functionality is built on :doc:`Zope 3 development patterns </components/index>`
like adapters and interfaces. These design patterns take some time to learn, but they are crucial in complex
component based software like Plone.


Development mode restarts
---------------------------

Plone must be started in the development mode using ``bin/instance fg`` command. Then

* Javascript files are in debug mode and automatically loaded when you hit refresh

* CSS files are in debug mode and automatically loaded when you hit refresh

* TAL page templates (.pt files) are automatically reloaded on every request

* :doc:`GenericSetup XML files are reloaded </components/genericsetup>`

Please note that Plone development mode does not reload ``.py`` or ``.zcml`` files by default.
This is possible, however.  Use the `sauna.reload <http://pypi.python.org/pypi/sauna.reload/>`_ package
to make Plone reload your Python code automatically when it is changed.

Through-the-web customizations
--------------------------------

Some aspects of Plone can be changed through the Zope Management Interface (ZMI).
Documentation here does not focus on extending functionality through the ZMI because this method is severely
limited and usually can take you only half way there.

Hello World Tutorial
----------------------

We have a :doc:`tutorial </getstarted/helloworld/index>` introducing the basics of Plone development.

The tutorial covers a basic form, a custom content-type, and a dynamic view. 
It also has detailed sections on building a development environment, installing Plone, and 
creating an add-on package for your development code.

More info
------------

.. toctree::
    :maxdepth: 1

    installation
    debug_mode
    python
    paste
    helloworld/index

Plone resources
=================

* `Plone Trac <http://dev.plone.org/plone>`_ contains bug reports, Plone source
  code and commits. Useful when you encounter a new exception or you are
  looking for a reference on how to use the API.

* `Plone source code in version control system <https://github.com/plone>`_.

* `Plone API (in development) <http://ploneapi.readthedocs.org/>`_.


Zope resources
==================

* `Zope source code in version control system <http://svn.zope.org/>`_.

* `Zope 2 book <http://docs.zope.org/zope2/zope2book/>`_. This describes old
  Zope 2 technologies. The book is mostly good for explaining some old things,
  but '''do not''' use it as a reference for building new things.

  The chapters on Zope Page Templates however are still the best reference
  on the topic.

