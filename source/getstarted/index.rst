==================
Getting started
==================

How to get started with Plone development.

Introduction
--------------

Plone is developed in :doc:`Python </getstarted/python>` programming language. You should master Python basics
before you can efficiently customize Plone.

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

Plone add-on features
-----------------------

Plone add-ons usually

* Create custom content types :doc:`content types </content/index>` or extend existing ones for your specialized need. Plone has
  two subsystem for content types. :doc:`Dexterity (new) </content/dexterity>` and :doc:`Archetypes (old) </content/archetypes/index>`.

* Add new :doc:`views </views/browserviews>` for your site and its content.

* Create Python processed :doc:`forms </forms/index>` on your site.

* Theme your site

* etc.

Internally Plone uses objected-oriented :doc:`ZODB </persistency/index>` database and the development
mindset greatly differs from SQL based system. SQL backends can be still integrated to Plone,
like to any Python applications.

A lot of Plone functionality extensivility is built on :doc:`Zope 3 development patterns </components/index>`
like adapters and interfaces. This design patters take some time to learn, but they are crucial in complex
component based software like Plone.

Creating your first add-on
----------------------------

Since Python egg packagestructure is little bit complex, to get started with your first add-on
you create a skeleton for its using :doc:`Plone templer templates </getstarted/paste>`.

* Templer generates basic Python egg package with some Plone files in-place

* This package is registered to buildout via development eggs in buildout.cfg file

* Buildout is rerun which regenerates your ``bin/instance`` script with new Python egg set

* You start Plone site in debug

* You install your add-on through ``Add/remove add-ons``

See `Hello World </getstarted/helloworld>`_ for example how to create your first Hello World application.

There are some alternative ways for add-on creation.

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
    helloworld


