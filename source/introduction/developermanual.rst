====================================================================
 How to update and maintain collective.developermanual
====================================================================

.. admonition:: Description

        This document explains how collective.developermanual
        package is maintained and how changes are pushed.

.. contents :: :local:

.. highlight:: console

Introduction
==============

This document concerns those who:

* Wish to generate a HTML version of Plone Community Developer manual

* Need to edit templates or styles of Plone Community Developer manual, or
  otherwise customize Sphinx process

* Need to deal with readthedocs.org integration

collective.developermanual
==========================

collective.developermanual_ is open-for-anyone-to-edit documentation for
Plone developers in Sphinx format, living in 
`Plone's collective Github version control system`_ (anyone can get commit
access, or, even easier, submit pull requests from their own github fork of
the repository).

.. _collective.developermanual: https://github.com/collective/collective.developermanual 
.. _Plone's collective Github version control system: https://github.com/collective

Sphinx_ is a tool that makes it easy to create intelligent and beautiful
documentation, written by Georg Brandl and licensed under the BSD license.

.. _Sphinx: http://sphinx.pocoo.org/

The ``collective.developermanual`` checkout contains 
:doc:`buildout.cfg recipes </tutorials/buildout/index>` to:

* install Sphinx;
* compile the manual to HTML;

Setting up software for manual compilation
=======================================================

First you need to install Git for your operating system to be able to
retrieve the necessary source code::

    sudo apt-get install git-core # Debian-based Linux
         
or::

    sudo port install git-core # Mac, using MacPorts

.. note::

    You must not have Sphinx installed in your Python environment (this will
    be the case if you installed it using ``easy_install``, for example).
    Remove it, as it will clash with the version created by buildout.  Use
    ``virtualenv`` if you need to have Sphinx around for other projects.

Then clone ``collective.developermanual`` from GitHub::

    git clone git://github.com/collective/collective.developermanual.git

See the
`git website <http://git-scm.com/>`_ 
for more information about git.

Run buildout to install Sphinx.
First step: bootstrap::

    python2.6 bootstrap.py
    ./bin/buildout

This will always report an error, but the ``bin/`` folder is created and
populated with the required scripts.  Now you need to checkout all the
source code using the *mr.developer* tool::

    ./bin/develop co ""

Run buildout again::

    ./bin/buildout

readthedocs.org
-----------------

The documentation is automatically synced to 
`readthedocs.org <http://collective-docs.readthedocs.org/>`_
by the readthedocs.org bot.

Pushing changes to GitHub is enough to publish the changes.        

Analytics
---------

http://readthedocs.org pages have the Google Analytics script installed.
Please ask on the #plone.org IRC channel for data access.

Building static HTML with Sphinx
=================================

This creates the ``docs/html`` folder from the source documents in the
``source`` folder, by compiling all the ``collective.developermanual``
pages, using the ``sphinx-build`` command from buildout::

    ./bin/sphinx-build source build

If you want to build everything from the scratch, to see all warnings::

    rm -rf build
    ./bin/sphinx-build                                     

.. What about the Makefile? The above commands could also be e.g. 
   ``make html``. Is the Makefile being deprecated?

Editing CSS styles
---------------------

When ``sphinx-build`` is run it copies stylesheets from *sources* to
*build*.

For live editing of CSS styles you might want to do::

    cp source/_static/plone.css build/_static

Then copy back::

    cp build/_static/plone.css source/_static    

.. note ::

    Firefox does not follow symlinks on file:// protocol, and cannot load
    CSS files from them.

More info

* http://sphinx.pocoo.org/templating.html

* https://bitbucket.org/birkenfeld/sphinx/src/65e4c29a24e4/sphinx/themes/basic


Compiling the HTML manual
--------------------------

Use the Sphinx makefile::

    make html

.. Should this be changed? To the following:
    ./bin/sphinx-build source build


Setting up CSS for http://plone.org
-----------------------------------

An example ``sphinx.css`` is provided with ``collective.developermanual``.

* It sets up CSS for default Sphinx styles (notices, warning, other
  admonition).  
* It sets up CSS for syntax highlighting.  
* It resolves some CSS class conflicts between Sphinx and the plone.org
  theme.

``sphinx.css`` assumes that a special Sphinx ``page.html`` template is used.
This template is modified to wrap everything which Sphinx outputs in the
``sphinx-content`` CSS class, so we can nicely separate them from standard
Plone styles.

``page.html`` can be found at ``sources/_templates/page.html``.


