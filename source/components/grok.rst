================
 Grok framework
================

.. admonition:: Description

        Using Grok framework in Plone programming. Grok
        provides  Dont-Repeat-Yourself API to create
        Zope 3 components easier.

.. contents :: :local:

Introduction
-------------

Grok is a project to give sane, easy to use, API to Zope 3 systems. 
It exists as standalone, but Plone compatible port five.grok is available for Plone 3.3 and onwards.

Benefits over using pure Zope 3 APIs

* No ZCML files or XML sit-ups needed (except bootstrapping one configure.zcml file)

* More things are automatic and less explicit hand-written code needed. E.g. template file and view class are automatically matched.

* Less code generation

Grok will automatically scan all .py files in your product and 
run registration code in them. This way you can use Python decorators
and magical classes to perform tasks which before needed to have 
hand written registration code.

More info

* http://grok.zope.org/

* http://pypi.python.org/pypi/five.grok

Tutorial
--------

* http://plone.org/products/dexterity/documentation/manual/five.grok

* http://www.martinaspeli.net/articles/using-grok-techniques-in-plone

Using Grok in your package
---------------------------

To enable grok'ing for your package:

* The top-level ``configure.zcml`` must include the ``grok`` namespace and
  the ``grok:grok`` directive. You do not need to put
  this directive subpackages. This directive scans your package source tree
  recursively for grok'ed files.

.. TODO: What does "You do not need to put this directive subpackages." mean?

* The package must be loaded using ``setup.py`` auto-include, NOT using a
  ``zcml =`` section in ``buildout.cfg``.
  Otherwise templates are not loaded.

* Optionally, add ``templates`` and ``static`` folders to your package root. 

* You still need to include subpackages for old-fashioned :term:`ZCML`
  configurations.

Example::

   <configure
       xmlns="http://namespaces.zope.org/zope"
       xmlns:five="http://namespaces.zope.org/five"
       xmlns:cmf="http://namespaces.zope.org/cmf"
       xmlns:i18n="http://namespaces.zope.org/i18n"
       xmlns:grok="http://namespaces.zope.org/grok"
       i18n_domain="plonetheme.xxx">

     <include package="five.grok" />

     <five:registerPackage package="." initialize=".initialize" />
   
     <!-- Grok the package to initialise schema interfaces and content classes -->
     <grok:grok package="." />
   
     <include package=".browser" />
   
   </configure>


More info
===========

Tutorials

* http://plone.org/products/dexterity/documentation/manual/five.grok/background/adding-five.grok-as-a-dependency

Steps

* Add dependency in your setup.py

* Edit buildout.cfg to include good known version set 

* Add grok ZCML directive to configure.zcml

