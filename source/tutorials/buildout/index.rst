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

.. toctree::


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
first time a given copy of a given buildout is set up, if an
existing buildout is moved, or if a different Python installation is
used.

To bootstrap, copy into the buildout directory the `bootstrap.py`
script from::

    http://svn.zope.org/*checkout*/zc.buildout/trunk/bootstrap/bootstrap.py

To establish the isolated Python environment, use the Python
installation that should be used for the buildout to run the
`bootstrap.py` script.  In my opinion, it is best to use the `-d`
option with the `bootstrap.py` script so that Buildout will use the
more actively maintained `distribute` project.  From that point on,
Buildout will use that Python installation for all subsequent Buildout
operations::

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


The Simplest buildout
=====================

The simplest buildout will deploy a Python distribution in an isolated
environment.  In this case we'll add the `sphinx` distribution to
our empty buildout and Buildout will retrieve that distribution, build
it, install it isolated in the buildout, and add any console scripts
to the `bin` directory.

We tell Buildout what the pieces of a deployment are by adding special
sections to the configuration called 'parts'.  Since deployments often
need to do many different kinds of things in the same deployment,
different parts need to be able to use different variables as options
and perform different logic and actions.  As such, Buildout uses
different Python code for different kinds of parts to provide specific
deployment behavior.  The Python code that handles a given buildout
part is called a `recipe`.

In the configuration file, a 'part' is just a named section that
provides a `recipe` variable, and whose section name is listed in the
`[buildout]` section's `parts` variable::

    [buildout]
    parts = sphinx

    [sphinx]
    recipe = zc.recipe.egg

In this case, we use the `zc.recipe.egg` recipe which is a part of the
Buildout project itself.  This recipe retrieves Python
distributions, installs them isolated to the buildout, and also
handles installing console scripts.  Later, we'll use part variables
as options to control the behavior of the recipe, but for now we'll
make use of the default behavior of `zc.recipe.egg` which is to get
the name of a single distribution to install from the part name.

Since we have already bootstrapped the buildout, haven't moved the
buildout directory, and we're using the same python, we do not need to
run the `bootstrap.py` script again.  We can just update our buildout
by re-running `bin/buildout`::

    $ bin/buildout 
    Getting distribution for 'zc.recipe.egg'.
    Got zc.recipe.egg 1.3.2.
    Installing sphinx.
    Getting distribution for 'sphinx'.
    Got Sphinx 1.1.3.
    Getting distribution for 'docutils>=0.7'.
    warning: ...
    zip_safe flag not set; analyzing archive contents...
    docutils.parsers.rst.directives.misc: module references __file__...
    Got docutils 0.8.1.
    Getting distribution for 'Jinja2>=2.3'.
    warning: ...
    Got Jinja2 2.6.
    Getting distribution for 'Pygments>=1.2'.
    Got Pygments 1.5.
    Generated script '/opt/src/buildout-tutorial/bin/sphinx-apidoc'.
    Generated script '/opt/src/buildout-tutorial/bin/sphinx-build'.
    Generated script '/opt/src/buildout-tutorial/bin/sphinx-quickstart'.
    Generated script '/opt/src/buildout-tutorial/bin/sphinx-autogen'.

Buildout tells us a bit about what it did while updating the
deployment to add the new part.  It retrieved, built, and installed
the Python distributions for the recipe, the distribution required by
the part, and all of their dependencies.  Note that it also reports
the versions it chose for the distributions it retrieved.  We'll
discuss how to specify and control those versions later.  Finally, it
installs the `console_scripts` specified in the `setup.py` of the
distribution specified in the part.

We've omitted some of the output that comes from building the eggs.
For context, that output most often occurs when building as
`setuptools` eggs Python distributions which only use Python's
`distutils`.  The warnings come from distribute and are often not
important but do on occasion indicate a genuine problem.
Unfortunately, there's no clear way for a user who isn't an expert in
Buildout and distribute to interpret whether or not there is a
problem.  With apologies, the best answer is to ignore such messages
until you have reason to think there is a problem.

At this point we can safely run the sphinx console scripts in an
isolated evnironment::

    $ bin/sphinx-apidoc --help
    Usage: sphinx-apidoc [options] -o <output_path> <module_path> [exclude_paths, ...]
    
    Look recursively in <module_path> for Python modules and packages and create
    one reST file with automodule directives per package in the <output_path>...


Section Variables and Part Options
==================================

So far, this buildout is just being used as an isolated distribution
installer, but a reproducible deployment is more often much more than
that.  Buildout is most useful for capturing and documenting the
specific details required by the deployment.  Recipes are responsible
for supporting those details and expect to be given options to that
end.  In the configuration file, those options are just the section
variables in the part that are recognized by the recipe.

The `zc.recipe.egg` recipe, for example, has a `dependent-scripts
<http://pypi.python.org/pypi/zc.recipe.egg/1.3.2#script-generation>`_
option.  If `true`, this option causes the recipe to install the
console scripts for any of the distribution's dependencies that define
console scripts::

    [buildout]
    parts = sphinx

    [sphinx]
    recipe = zc.recipe.egg
    dependent-scripts = true

Now when `bin/buildout` is run, the `pygmentize` console script from
the `Pygments` dependency of `sphinx` is also installed::

    $ bin/buildout
    Uninstalling sphinx.
    Installing sphinx.
    Generated script '/opt/src/buildout-tutorial/bin/sphinx-apidoc'.
    Generated script '/opt/src/buildout-tutorial/bin/sphinx-build'.
    Generated script '/opt/src/buildout-tutorial/bin/sphinx-quickstart'.
    Generated script '/opt/src/buildout-tutorial/bin/sphinx-autogen'.
    Generated script '/opt/src/buildout-tutorial/bin/pygmentize'.
    $ bin/pygmentize --help
    Usage: bin/pygmentize [-l <lexer> | -g] [-F <filter>[:<options>]] [-f <formatter>]
              [-O <options>] [-P <option=value>] [-o <outfile>] [<infile>]...
