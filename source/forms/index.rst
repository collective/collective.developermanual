================================================
Forms, models, fields and widgets
================================================

Plone includes several alternative form mechanisms:

For content-oriented forms:

* :doc:`Dexterity </getstarted/dexterity>` for Plone 4.1+

* :doc:`Archetypes </reference_manuals/old/archetypes/index>` is used for content types in Plone 3.x

For convenience forms built and maintained through-the-web:

* :doc:`PloneFormGen <ploneformgen>`

For utility forms supported by custom code:

* z3c.form for Plone 4.x

* zope.formlib is used for stock forms in Plone 3.x

This documentation applies only for form libraries.

You need to identify which form library you are dealing with and read the form library specific
documentation.

Zope 3 schema (zope.schema package) is database-neutral an framework-neutral way to describe Python data models.

.. toctree::
    :maxdepth: 1

    manual
    schemas
    z3c.form
    files
    formlib/index
    vocabularies
    wysiwyg
    ploneformgen