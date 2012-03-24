==========
 Glossary
==========

This is a glossary for some definitions used in this documentation and
still heavily under construction.

For a more complete glossary, please refer to `glossary on plone.org <http://plone.org/documentation/glossary>`_.

.. glossary:: :sorted:

   Egg
     A widely used Python packaging format which consists of a zip or
     ``.tar.gz`` archive with some metadata information, introduced by
     `setuptools <http://peak.telecommunity.com/DevCenter/EasyInstall>`_ which has
     now been superseded by 
     `Distribute <http://packages.python.org/distribute/>`_.

   reStructuredText
     The standard plaintext markup language used for Python
     documentation: http://docutils.sourceforge.net/rst.html

   slug
      A ZCML *slug* is a one-liner created in the zope instance's
      *etc/package-includes* directory, with a name like
      *my.package-configure.zcml* which is the Zope 3 way to load
      a particular package. e.g.
      ``<include package="my.package" file="configure.zcml" />``


