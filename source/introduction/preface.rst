=======
Preface
=======

Plone and its accompanying technologies have been built over the course of many
years. The codebase contains over 6000 modules. Even the masterminds don't get
it always on the first try: over the years, generations of technologies for the
same function have come and gone, leaving their mark on the code. There are
technologies which were built when HTTP was just becoming mainstream. There are
technologies which were built when the Python programming language was still
young, lacking vast amounts of power and standard library functionality
available nowadays. Then there are the new trends that influence how things
should be done, which displace older approaches that may have hit limitations.

The results of hundreds of man-years of code evolution, to develop a
comprehensive feature set, comes at a price. While Plone tends to cover even
the most remote corner cases, this comprehensiveness brings complexity, which
in turn can make simple things unnecessarily difficult.

Plone is easily one of the most complex Python projects, and no human person
can master it perfectly. It is not always easy to figure out how everything is
interacting, especially when there are several ways of doing the same thing.
There may or may not be good documentation, but due to the vast number of
possible needs, most of them are uncovered. The documentation itself is
distributed to the separate domains of knowledge from different ages.

When you encounter something you want to get accomplished, but you are unable
to find direct examples of how to do it, you can resort to the two following
methods:

* Ask for help. Try the ``#plone`` IRC channel on freenode [1]_ and the
* product-developers email list [2]_. The help might not arrive instantly.
  You'll increase chances to get a fellow giving you a helping hand if you can
  provide very detailed descriptions of your problem. People are also
  voluntarily helping you; it is not feasible to push them for more they can
  give for you.

* Search through the codebase. Search references and clues from all the Python,
  ZCML, XML, Javascript and Page Template files found in the codebase by task
  keywords. After you find hits, read through the code until you have figured
  out how all different subsystems interface.

Be patient. Be aware that you are dealing with a complex system and you need to
reserve time to manage technology and minimize risks. The worst unknowns are
unknowns you don't know are unknowns. But remember: there are never things you
cannot do or things you cannot know. There is no black box |---| the codebase is
all open. With enough patience, you can study it and find solutions to all
problems. If the stock code does not do it, you can easily monkey-patch the
existing modules to bend them to your will, or in the most extreme situations
you can fork the entire project.

.. [1] http://plone.org/support/chat
.. [2] http://plone.org/support/forums/addons

.. |---| unicode:: U+02014 .. em dash
