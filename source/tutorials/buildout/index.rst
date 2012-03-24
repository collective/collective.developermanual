=================
Buildout Tutorial
=================

`Buildout <http://www.buildout.org/>`_ can seem far more complex than
it really is if you're new to it and are trying to understand an
`existing buildout
<https://github.com/plone/Installers-UnifiedInstaller/blob/master/buildout_templates/base.cfg>`_.
A single buildout can grow to do quite a lot, but a buildout also need
only be complex as what it's being used to do.  This document aims to
help the reader understand the core concepts of Buildout starting with
the simplest possible buildout and working through increasingly
complex buildouts.  At the end, the reader should be able to walk up
to an existing complex buildout and understand what it does.


Why Buildout?
=============

The primary purpose of Buildout is reproducible deployments.  A
deployment can be a number of things from as simple as installing a
python script in an isolated directory and environment to a full web
application deployment containing multiple pieces and a lot of
configuration.  To that end Buildout provides a number of services:

Describing Deployments
    Buildout is best used to define and describe what a given deployment
    needs to contain and how to configure it.  The buildout can then be
    used to reliably reproduce that deployment in multiple locations and
    environments.  You can keep your buildout in version control, check it
    out in multiple locations, such as staging, production, and on each
    team members workstation and trust that there is consistency between
    them all.

Factoring Deployment Configuration
    Another element of reproducible deployments is to allow sharing
    common pieces of slightly different deployments.  For example,
    when building a web application you often want to use tools for
    development that should never be deployed to production, but you
    also need to be able to trust that your development environment
    otherwise reflects what will be deployed to production.  Buildout
    provides ways to factor deployment configuration such that you can
    use the same buildout for development and production but specify
    which variation of the buildout should be used in each
    environment.

Deployment Isolation
    Another important element of reproducible deployments is
    isolation, ensuring that the deployment won't be interfered with
    or interfere with other things in the same environment.  To that
    end, a buildout deployment `provides an isolated Python
    environment
    <http://pypi.python.org/pypi/zc.buildout/1.5.2#system-python-and-zc-buildout-1-5>`_
    into which Buildout can install Python distributions which won't
    interfere with anything outside the buildout or be interfered with
    by things outside the buildout.

Installing Software
    Finally, a big part of any real-world deployment is retrieving,
    building and installing software.  Another important part of that
    is doing the same for any dependencies of that software.  As such,
    Buildout uses `distribute
    <http://packages.python.org/distribute/>`_ and provides it's own
    version of `easy_install
    <http://packages.python.org/distribute/easy_install.html>`_ to do
    this for Python software.

While built on Python, some of the core services Buildout provides are
Python specific, and Buildout is most useful on Python projects, there
is nothing necessarily Python specific about using what a buildout
deploys and it can be used for non-Python projects.


'Buildout' as a Technical Term
==============================

A common source of confusion is the fact that 'buildout' as a term can
apply to two things that a user of Buildout will frequently have to
deal with.  The first meaning of 'Buildout' is to refer to
`zc.buildout` the software.  This includes the `bin/buildout` script
or when referring to running 'Buildout'.  The other meaning is to
refer to the individual deployment directory as 'a buildout'.  IOW,
when you checkout from version control into a working copy directory
that uses 'Buildout' the software, that directory is 'a buildout'.  To
limit confusion about this, this tutorial uses 'Buildout' with a
capital 'B' to refer to the software and 'a buildout' with a lower
case 'b' to refer to a specific copy of a buildout in a specific
directory.


A Simple buildout
=================

A buildout configuration describes a deployment.  This description is
written in configuration files, named with a `.cfg` extension by
convention.  These files use an extended `ConfigParser
<http://docs.python.org/library/configparser.html>`_ format from the
Python standard library.  You'll likely recognize this format as a
very common configuration file format consisting of named 'sections',
defined by a line with the section name in brackets.  These sections
then contain named variables with values.

The core configuration of any buildout deployment is described in the
`[buildout]` section.  A buildout deployment consists of 'parts',
which are special configuration sections.  The default configuration
file is `buildout.cfg`.  As such, to create the simplest possible
buildout, which is an empty deployment, create an empty directory and
put the following into a `buildout.cfg` file in that directory::

    [buildout]
    parts =

Now that the deployment is described in the configuration file we can
use Buildout to deploy the empty environment described.  Deploying a
buildout has two steps.  The first step defines which Python
installation to use for that buildout and establishes the isolated
Python environment described in `Why Buildout`_.  This step also gets
the minimum requirements necessary to use the Buildout software
itself.  This step is called bootstrapping and is only necessary the
first time a given copy of a given buildout is set up, or if an
existing buildout is moved.

To bootstrap, copy into the buildout directory the `bootstrap.py`
script from::

    http://svn.zope.org/*checkout*/zc.buildout/trunk/bootstrap/bootstrap.py

To establish the isolated Python environment, use the Python
installation that should be used for the buildout to run the
`bootstrap.py` script.  From that point on, Buildout will use that
Python installation for all subsequent Buildout operations::

    $ /path/to/python bootstrap.py -d
    Creating directory '/opt/src/buildout-tutorial/bin'.
    Creating directory '/opt/src/buildout-tutorial/parts'.
    Creating directory '/opt/src/buildout-tutorial/develop-eggs'.
    Generated script '/opt/src/buildout-tutorial/bin/Buildout'.

Now the directory has three new directories, whose purposes will be
come clear in the next chapter, and a `bin/buildout` script (or
`bin\buildout.exe` on Windows) which is used to apply the deployment
configuration.  Since this buildout configuration describes an empty
deployment, running Buildout does nothing::

    $ bin/buildout

Next, we'll move beyond an empty buildout to an example of the
simplest possible buildout that actually deploys something.
