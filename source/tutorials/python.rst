=======================
 Python, Plone and Zope
=======================

.. admonition:: Description

    The basics of Python programming, and performing Python interpreter installations.

.. contents :: :local:

.. highlight:: console

Introduction
=============

`Python <http://python.org>`_ is the programming language used by 
`Plone <http://plone.org>`_ and `Zope <http://zope.org>`_.

Python Tutorials
===============================

* Official Python tutorial: http://docs.python.org/tutorial/

* Google Python classes:
  http://code.google.com/edu/languages/google-python-class/

Plone and Zope resources
==========================

Plone resources
----------------

* `Plone Cheat Sheet <http://www.coactivate.org/projects/plonecheatsheet>`_. A
  single list of every technology you need to learn to develop with plone, why
  you need it and how to learn it. A bit out of date, but a good overview
  nonetheless.

* `Plone Trac <http://dev.plone.org/plone>`_ contains bug reports, Plone source
  code and commits. Useful when you encounter a new exception or you are
  looking for a reference how to use the API.

* `Plone source code in version control system <http://svn.plone.org/svn/plone>`_.

Zope resources
----------------

* `Zope 3 API reference <http://apidoc.zope.org/>`_. Good source for up-to-date
  Zope Python API and ZCML references.

* `Zope 2 book <http://docs.zope.org/zope2/zope2book/>`_. This describes old
  Zope 2 technologies. The book is mostly good for explaining some old things,
  but '''do not''' use it as a reference for building new things.

  The chapters on Zope Page Templates however are still the best reference
  on the topic.

.. TODO:: hyperlink 

* `Zope source code in version control system <http://svn.zope.org/>`_.

* `Zope package guide <http://wiki.zope.org/zope3/Zope3PackageGuide>`_.

Installing Python
=================

It is not recommended to use the system-wide Python installation with Plone.
There are various reasons for this:

- Plone may require newer or older package versions, which could conflict
  with ones installed by your operating system.
- Installing packages to the system-wide Python installation always requires
  root privileges, and you could easily hose your box when doing Python
  development work.
- You may want to work on different Plone instances, with different versions
  of Zope and different sets of modules installed.

Plone Unified Installers compile their own, preconfigured, Python
interpreter.

If you are a developer, you might wish to use a custom-built Python
interpreter, which gives you more control over the configuration.

Installing Plone via Unified Installer
==============================================================

This is the recommended method if you are not familiar with Python development.

Installing Plone under Ubuntu / Debian
-------------------------------------------

Below is a recommended method for installations for 

* Lightweight production sites

* Plone development and testing on Ubuntu / Debian  

Instructions tested for Ubuntu 10.04 Long Term Support release.

Create new UNIX user (e.g. user ``plone``)::

     adduser plone

.. note ::

   It is not recommended to run Plone under root user.

Install operating system prerequisitements::

     sudo apt-get install python-dev build-essential libssl-dev

Log-in as this user::

     sudo -i -u plone

Download Plone unified binary from `download page to your server <http://plone.org/download>`_

     wget https://launchpad.net/plone/4.1/4.1.4/+download/Plone-4.1.4-UnifiedInstaller.tgz

Run the installer as non-root standalone mode::
   
     ./install.sh standalone

Admin username is printed in the console. You can change this password after logging
into the Zope Management Interface. 

.. note ::

    The password is also written down in buildout.cfg file, but this setting is not 
    effective after Plone has been started for the first time. Changing this setting
    does not do any good.

Start Plone in development mode for a test run (you'll see potential errors in the console)::

     cd ~/Plone/
     bin/instance fg

By default, Plone will listen to all available network interfaces and port 8080.

Now enter to Plone site by entering address 

     http://yourserver:8080 

... to your webbrowser.

Zope, the application server under Plone, will ask you to create a new site.
For this you need the login credentials outputted into your terminal earlier.

If everything is ok press *CTRL + C* in the terminal to stop Plone in debug mode.

Then start Plone in production mode. In the production mode 
Plone does not reload file changes on the file system and also stays running even if you
disconnect the terminal session::
  
    bin/instance start
  
If you have problems `please see help guidelines <http://plone.org/help>`_.

For automatic start-ups on your server boots up, init scripts, etc.
please see :doc:`hosting guide </hosting>`. 

Installing Plone via buildout
===============================

Here are quick instructions to install Plone using buildout and OS provided Python interpreter.
You need to manage dependencies (libxml, Pillow) yourself.

This will:

* create a default ``buildout.cfg`` configuration file and folder structure
  around it;
* automatically download and install all packakges from `pypi.python.org <pypi.python.org>`_
* configure Plone and Zope for you.

Install virtualenv for python (on Ubuntu)::

      sudo apt-get install python-virtualenv

Create a virtualenv where you can install some Python packages (ZopeSkel,
Pillow)::
  
      virtualenv plone-virtualenv

In this virtualenv install ZopeSkel (from the release 2 series)::

    source plone-virtualenv/bin/activate
    easy_install "ZopeSkel<2.99"

Create Plone buildout project using ZopeSkel::

    paster create -t plone4_buildout myplonefolder

Optionally edit buildout.cfg in this point.
Run buildout (use Python 2.6 for Plone 4.1)::

    python2.6 bootstrap.py
    bin/buildout

More info:

* :doc:`ZopeSkel </tutorials/paste>` 
* `virtualenv <http://pypi.python.org/pypi/virtualenv>`_ 
* `Pillow <http://pypi.python.org/pypi/Pillow/>`_ 
* `lxml <http://lxml.de/>`_

Installing Plone 4.1 on Windows
==================================

* How to change location

* How to rebuild installer

Please see

* https://docs.google.com/document/d/19-o6yYJWuvw7eyUiLs_b8br4C-Kb8RcyHcQSIf_4Pb4/edit

* http://plone.org/documentation/kb/using-buildout-on-windows


