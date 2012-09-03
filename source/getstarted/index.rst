==================
Getting started
==================

How to get started with Plone development.

.. contents:: :local:

Introduction
--------------

Plone is developed in :doc:`Python </getstarted/python>` programming language. You should master Python basics
before you can efficiently customize Plone. If you are very new to Python, Plone or software development
generally it is suggested that you read `Professional Plone 4 Development book <https://plone.org/documentation>`_ 
before you attempt to develop your own solutions.

Plone runs on the top of `Zope 2 application server <zope2.zope.org/>`_ meaning that one Zope 2 server process
can contain and host several Plone sites. Plone also uses Zope 3 components. Zope 3 is not upgrade for Zope 2,
but a separate project.

Internally Plone uses objected-oriented :doc:`ZODB </persistency/index>` database and the development
mindset greatly differs from SQL based system. SQL backends can be still integrated to Plone,
like to any Python applications.

Installing Plone
------------------

It is recommended that you do Plone development on Linux or OSX. Development on Windows is possible,
but you need to have much more experience dealing with Python and Windows related problems, so starting on Windows is not so easy.

See :doc:`installation instructions </getstarted/installation>` for how to create a Plone installation suitable for development.

Plone add-ons as Python packages
-----------------------------------

Plone can be customized for your needs by creating addons which are developed and distributed `Python egg packages <http://packages.python.org/distribute/setuptools.html>`_. Python egg is a Python packaing format. Open source Python packages are listed and automatically downloaded from `pypi.python.org <http://pypi.python.org>`_
service.

The set of components, which makes your Plone installation, is managed by :doc:`bin/buildout command and buildout.cfg configuration </buildout/index>`. Buildout itself wraps around Python's setuptools and easy_install commands.

Creating your first add-on
----------------------------

Since Python egg packagestructure is little bit complex, to get started with your first add-on
you create a code skeleton (scaffold) for its using :doc:`Plone ZopeSkel code templates </getstarted/paste>`.

* ZopeSkel generates basic Python egg package with some Plone files in-place

* This package is registered to buildout via development eggs in buildout.cfg file

* Buildout is rerun which regenerates your ``bin/instance`` script with new Python egg set

* You start Plone site in debug

* You install your add-on through ``Add/remove add-ons``

.. note ::

  There are different scaffolds for different kind of add-ons. Most usual are plone3_theme,
  archetypes (create Archetypes content), dexterity (create Dexterity content) and plone
  (barebone Plone add-on).

Please read how to use :doc:`ZopeSkel to bootstrap your first add-on </getstarted/paste>`.

Plone development workflow
----------------------------

You never edit Plone files directly. Everything under ``parts`` and `eggs``
folders in your Plone installation are downloaded from internet and dynamically generated
based by ``buildout.cfg``. Plone is free to override these files on any update.

You need to have your own add-on in ``src/`` folder as created above.  
There you overlay changes to existing Plone core through extension mechanisms provided by Plone

* :doc:`Layers </views/layers>`

* :doc:`Adapters </components/adapters>`

* :doc:`Installation profiles </components/genericsetup>`

Plone development always happens on your local computer or the development server.
The changes are moved to the production through version control system like Git or Subversion.

**The best practice is that you install Plone on your local computer for the development**.

Plone add-on features
-----------------------

Plone add-ons usually

* Create custom content types :doc:`content types </content/index>` or extend existing ones for your specialized need. Plone has
  two subsystem for content types. :doc:`Dexterity (new) </content/dexterity>` and :doc:`Archetypes (old) </content/archetypes/index>`.

* Add new :doc:`views </views/browserviews>` for your site and its content.

* Create Python processed :doc:`forms </forms/index>` on your site.

* Theme your site

* etc.

A lot of Plone functionality extensivility is built on :doc:`Zope 3 development patterns </components/index>`
like adapters and interfaces. This design patters take some time to learn, but they are crucial in complex
component based software like Plone.


Development mode restarts
---------------------------

Plone must be started in the development mode using ``bin/instance fg`` command. Then

* Javascript files are in debug mode and automatically loaded when you hit refresh

* CSS files are in debug mode and automatically loaded when you hit refresh

* TAL page templates (.pt files) are automatically reloaded on every request

* :doc:`GenericSetup XML files are reloaded </components/genericsetup>`

Please note that Plone development mode does not reload ``.py`` or ``.zcml`` files by default.
This is possible, however.  Yse `sauna.reload <http://pypi.python.org/pypi/sauna.reload/>`_ package
to make Plone reload your Python code.

Through-the-web customizations
--------------------------------

Some aspects of Plone can be changed through Zope Management web interface.
Documentation here does not focus for extending fuctionality through this method because

* It is discouraged, because

* it is seriously limited and usually can take you only half way there

More info
------------

.. toctree::
    :maxdepth: 1

    installation
    python
    paste
    helloworld/index

Plone resources
=================

* `Plone Trac <http://dev.plone.org/plone>`_ contains bug reports, Plone source
  code and commits. Useful when you encounter a new exception or you are
  looking for a reference how to use the API.

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

