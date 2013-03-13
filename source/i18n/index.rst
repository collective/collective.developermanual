============================
Internationalization (i18n)
============================

Plone has three different internationalization subsystems:

* Translating user interface text strings by using term:`gettext`, like the
  `zope.i18n`_ and `zope.i18nmessageid`_ packages.

* Adapting locale-specific settings (such as the time format) for the site,
  like the `plone.i18n`_ package.

* Managing multilingual content: the `Products.LinguaPlone`_ add-on product.

.. _zope.i18n: http://pypi.python.org/pypi/zope.i18n
.. _zope.i18nmessageid: http://pypi.python.org/pypi/zope.i18nmessageid
.. _plone.i18n: http://pypi.python.org/pypi/plone.i18n
.. _Products.LinguaPlone: http://pypi.python.org/pypi/Products.LinguaPlone


.. toctree::
    :maxdepth: 1

    internationalisation
    language
    translating_content
    contribute_to_translations
    cache
