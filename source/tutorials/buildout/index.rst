=================
Buildout Tutorial
=================

`Buildout <http://www.buildout.org/>`_ can seem far more complex than
it really is if you're new to it and are trying to understand an
`existing buildout
<https://github.com/plone/Installers-UnifiedInstaller/blob/master/buildout_templates/base.cfg>`_.
A single buildout can grow to do quite a lot, but a buildout also need
only be complex as what it's being used to do.  This document aims to
help the reader understand the core concepts of buildout starting with
the simplest possible buildout and working through increasingly
complex buildouts.  At the end, the reader should be able to walk up
to an existing complex buildout and understand what it does.


Why Buildout?
=============

The primary purpose of buildout is reproducible deployments.  A
deployment can be a number of things from as simple as installing a
python script in an isolated directory and environment to a full web
application deployment containing multiple pieces and a lot of
configuration.  To that end buildout provides a number of services:

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
    Another important element of reproducible deployments is isolation,
    ensuring that the deployment won't be interfered with or interfere
    with other things in the same environment.  To that end, a buildout
    deployment provides an isolated Python environment into which buildout
    can install Python distributions which won't interfere with anything
    outside the buildout or be interfered with by things outside the
    buildout.

Installing Software
    Finally, a big part of any real-world deployment is retrieving,
    building and installing software.  Another important part of that
    is doing the same for any dependencies of that software.  As such,
    buildout uses `distribute
    <http://packages.python.org/distribute/>`_ and provides it's own
    version of `easy_install
    <http://packages.python.org/distribute/easy_install.html>`_ to do
    this for Python software.

While built on Python, some of the core services buildout provides are
Python specific, and Buildout is most useful on Python projects, there
is nothing necessarily Python specific about using what a buildout
deploys and it can be used for non-Python projects.


A Simple Buildout
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
use buildout to deploy the empty environment described.  Deploying a
buildout has two steps.  The first step defines which Python
installation to use for that buildout and gets the minimum
requirements necessary to use the buildout software itself.  This step
is called bootstrapping and is only necessary the first time a given
copy of a given buildout is set up, or if an existing buildout is
moved.  To bootstrap, copy the `bootstrap.py
<http://svn.zope.org/*checkout*/zc.buildout/trunk/bootstrap/bootstrap.py>`_
script into the buildout directory and run it with the Python
installation which should be used.  From that point on, buildout will
use that Python for all subsequent buildout operations and the Python
installation used by for a deployment of a Python project::

    $ /path/to/python bootstrap.py -d
    Creating directory '/opt/src/buildout-tutorial/bin'.
    Creating directory '/opt/src/buildout-tutorial/parts'.
    Creating directory '/opt/src/buildout-tutorial/develop-eggs'.
    Generated script '/opt/src/buildout-tutorial/bin/Buildout'.

Once the buildout is bootstrapped, use the `bin/buildout` script to
deploy.  Since this buildout configuration describes an empty
deployment, running buildout does nothing::

    $ bin/buildout
