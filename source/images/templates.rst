=========================
Images in page templates
=========================

.. admonition:: Description

    How to link to images in page templates in Plone.

.. contents:: :local:

Putting a static image into a page template
=============================================

Here is an example how to create an ``<img>`` tag in a ``.pt`` file:

.. code-block:: html

    <img tal:attributes="src string:${context/@@plone_portal_state/portal_url}/++resource++plonetheme.mfabrik/close-icon.png" alt="[ X ]"/>

Let's break this down:

* Obviously we are rendering an ``<img>`` tag.

* The ``src`` attribute is dynamically generated using a :term:`TALES`
  expression.

* We use *string comprehension* to create the ``src`` attribute.
  Alternatively we could use e.g. the ``python:`` :term:`TALES` expression
  type and embed one line python of code to generate the attribute value.

* We look up a helper view called :doc:`plone_portal_state </misc/context>`.
  This is a ``BrowserView`` shipped with Plone. Its purpose is to expose
  different helper methods to page templates and Python code.

* We call ``plone_portal_state``'s ``portal_url()`` method. This will return
  the root URL of our site.
  Note that this is not necessary the domain's top-level URL,
  as Plone sites can be nested in folders, or served on a path among
  unrelated web properties.

* We append our Zope 3 resource path to our site root URL (see below). This
  maps to some static media folder in our add-on files on the disk.

* There we point to ``close-icon.png`` image file.

* We also add the ``alt`` attribute of the ``<img>`` tag normally.
  It is not dynamically generated.

When the page template is generated, the following snippet could look like,
for example:

.. code-block:: html 

    <img src="http://localhost:8080/mfabrik/++resource++plonetheme.mfabrik/logo.png" alt="[ X ]">

... or:

.. code-block:: html 

    <img src="http://mfabrik.com/++resource++plonetheme.mfabrik/logo.png" alt="[ X ]">

... depending on the site virtual hosting configuration.

Relative image look-ups
-----------------------

.. warning::

    Never create relative image look-ups without prefixing the image source
    URL with the site root.

Hardcoded relative image path might seem to work:

.. code-block:: html 

    <img src="++resource++plonetheme.mfabrik/logo.png" >

... but this causes a different image *base URL* to be used on every page.
The image URLs, from the browser point of view, would be:

.. code-block:: html 

    <img src="http://yoursite/++resource++plonetheme.mfabrik/logo.png" >

... and then in another folder:

.. code-block:: html 

    <img src="http://yoursite/folder/++resource++plonetheme.mfabrik/logo.png" >
              
... which **prevents the browser from caching the image**.
              
Registering static media folders in your add-on product
=========================================================

Zope 3 resource directory
-------------------------

The right way to put in a static image is to use a Zope 3 resource
directory.

* Create folder ``yourcompany.product/yourcompany/product/browser/static``.

* Add the following :term:`ZCML` to
  ``yourcompany.product/yourcompany/product/browser/configure.zcml``.

.. code-block:: xml

    <browser:resourceDirectory
        name="yourcompany.product"
        directory="static"
        layer=".interfaces.IThemeSpecific"
        />

This will be picked up at the ``++resource++yourcompany.product/`` static
media path.

Layer is optional: the static media path is available only 
when your add-on product is installed if the 
:doc:`layer </views/layers>` is specified.
        
Grok static media folder
------------------------

This applies for add-on products using :doc:`five.grok </components/grok>` API.

Create folder ``yourcompany.product/yourcompany/product/static``

This will be automatically picked up as ``++resource++yourcompany.product/``
static media path 
when a Grok'ed add-on is launched.

Rendering Image content items
======================================

You can refer to ``ATImage`` object's content data download by adding
``/image`` to the URL:

.. code-block:: html

    <img alt="" tal:attributes="src string:${context/getImage/absolute_url}/image" />
        
The magic is done in the ``__bobo_traverse__`` method of ``ATImage`` by
providing traversable hooks to access image download:

* http://svn.plone.org/svn/collective/Products.ATContentTypes/trunk/Products/ATContentTypes/content/image.py

Rendering ``ImageField`` 
=======================

Archetypes's ``ImageField`` maps its data to the content object at attribute
which is the field's name.
If you have a field ``campaignVideoThumbnail`` you can generate an image tag
as follows:

.. code-block:: html 

    <img class="thumbnail" tal:attributes="src string:${campaign/absolute_url}/campaignVideoThumbnail" alt="Campaign video" />

If you need more complex ``<img>`` output,
create a helper function in your ``BrowserView`` and use Python code 
to perform the ``ImageField`` manipulation.

See ``ImageField`` for more information:

* http://svn.plone.org/svn/archetypes/Products.Archetypes/trunk/Products/Archetypes/Field.py         

``tag()`` method
==================

.. note::

    Using ``tag()`` is discouraged. Create your image tags manually.

Some content provides a handy ``tag()`` method to generate 
``<img src="" />`` tags
with different image sizes.

``tag()`` is available on

* Archetypes ``ImageField``

* ``ATNewsItem``

* ``ATImage``

* ``FSImage`` (Zope 2 image object on the file-system)

``tag()`` is defined in `OFS.Image <http://svn.zope.org/Zope/trunk/src/OFS/Image.py?rev=96262&view=auto>`_.

Scaling images
--------------

``tag()`` supports scaling. Scale sizes are predefined.
When an ``ATImage`` is uploaded,
various scaled versions of it are stored in the database.

Displaying a version of the image using the "preview" scale::

	image.tag(scale="preview", alt="foobar text")

This will generate:

.. code-block:: html 

	<img src="http://something/folder/image/image_preview" alt="foobar text" />

.. note::

	If you are not using the ``alt`` attribute, you should set it to an
	empty string: ``alt=""``. Otherwise screen readers will read
	the ``src`` attribute of the ``<img>`` tag aloud.

In order to simplify accessing these image scales, use
`archetypes.fieldtraverser <http://pypi.python.org/pypi/archetypes.fieldtraverser>`_.
This package allows you to traverse to the stored image scales while still
using ``AnnotationStorage`` and is a lot simpler to get going (in the
author's humble opinion :).

Default scale names and sizes are defined in ``ImageField`` declaration for
custom ``ImageField``\s.
For ``ATImage``, those are in 
`Products.ATContentTypes.content.image
<http://svn.plone.org/svn/collective/Products.ATContentTypes/trunk/Products/ATContentTypes/content/image.py>`_.

