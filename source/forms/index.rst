================================================
Forms, models, fields and widgets
================================================

Plone includes several alternative form mechanisms

* Dexterity and z3c.form are recommended approaches for Plone 4.1+

* Archetypes is used for content types in Plone 3.x

* zope.formlib is used for stock forms in Plone 3.x

You need to identify which form library you are dealing with and read the form library specific
documentation.

Archetypes forms cannot be used outside content management. Please read more about Archetypes
in Content section. This documentation applies only for form libraries.

Zope 3 schema (zope.schema package) is database-neutral an framework-neutral way to describe Python data models.

.. toctree::
    :maxdepth: 1

    manual
    schemas
    z3c.form
    files
    formlib/index
    ploneformgen
    vocabularies
    wysiwyg
