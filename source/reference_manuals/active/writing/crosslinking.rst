====================================================================
 Embedded external manuals
====================================================================

.. admonition:: Description

    How to get your Plone package documentation into
    collective-docs.

.. highlight:: console

Introduction
=======================

The audience of this documentation are Plone developers
who are writing Plone core Python packages.

collective.developermanual has a section *Reference manuals*

* You can pull in manuals to this section from external packages

* Then these manuals can be cross-references in the other documentation

* All documentation is one place to be found for the fellow peer developers

Steps to embed a reference manual
=======================================

Add your egg source to ``requirements.txt``.

Add directory mapping to the top of ``conf.py``.

Add a reference in ``source/index.rst`` to point your master ``index.rst``.

Then run Sphinx::

    bin/buildout
    make html

See that your manual gets correctly added in the index::

    open build/html/index.html
