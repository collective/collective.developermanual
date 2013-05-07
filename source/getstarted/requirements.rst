===============================
Plone Installation Requirements
===============================

.. admonition:: Description

    Requirements for installing Plone. Details the tools and libraries
    (dependencies) required to install Plone.

.. contents:: :local:

.. highlight:: console

All versions
============

A complete GNU build kit including GCC including gcc, gmake, patch, tar,
gunzip, bunzip2, wget.

Most required libraries listed below must be installed as development versions (dev).

Tools and libraries marked with "*" are either included with the Unified
Installer or automatically downloaded.

If you use your system Python, you should use Python's virtualenv to create an
isolated virtual Python. System Pythons may use site libraries that will
otherwise interfere with Zope/Plone.

Optional libraries
------------------

If Plone can find utilities that convert various document formats to text, it will include them in the site index. To get PDFs and common office automation formats indexed, add:

* poppler-utils (PDFs)
* wv (office docs)

These may be added after initial installation.

Plone 4.3 / 4.2
===============

Python
------

Python 2.7 (dev), built with support for expat (xml.parsers.expat), zlib and ssl.*

virtualenv*

Libraries
---------

* libz (dev)
* libjpeg (dev)*
* readline (dev)*
* libssl or openssl (dev)
* libxml2 >= 2.7.8 (dev)*
* libxslt >= 1.1.26 (dev)*

Plone 4.1
=========

Python
------

Python 2.6 (dev), built with support for expat (xml.parsers.expat), zlib and ssl.*

virtualenv*

Libraries
---------

* libz (dev)
* libjpeg (dev)*
* readline (dev)*


Minimal build
=============

With complete requirements in place, a barebones Plone install may be created
with a few steps. '~...#' is a system prompt. Adjust the Plone and Python
versions to match your requirements::

    ~/$ mkdir Plone-4.3
    ~/$ cd Plone-4.3
    ~/Plone-4.3$ virtualenv --distribute Python-2.7
    ~/Plone-4.3$ mkdir zinstance
    ~/Plone-4.3$ cd zinstance
    ~/Plone-4.3$ wget http://downloads.buildout.org/1/bootstrap.py
    ~/Plone-4.3/zinstance$ echo """
    > [buildout]
    >
    > extends =
    >     http://dist.plone.org/release/4.3/versions.cfg
    >
    > parts =
    >     instance
    >
    > [instance]
    > recipe = plone.recipe.zope2instance
    > user = admin:admin
    > http-address = 8080
    > eggs =
    >     Plone
    >     Pillow
    > """ > buildout.cfg
    ~/Plone-4.3/zinstance$ ../Python-2.7/bin/python bootstrap.py --distribute
    ~/Plone-4.3/zinstance$ bin/buildout
      Long download and build process ...
      Errors like "SyntaxError: ("'return' outside function"..."" may be ignored.

This build will install Plone, ready to be run with::

    ~/Plone-4.3/zinstance$ bin/instance start

running attached to port 8080.

This build would be adequate for a quick evaluation installation. For a
production or development installation, use one of `Plone's installers
<http://plone.org/products/plone>`_.
