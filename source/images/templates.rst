=========================
Images in page templates
=========================

.. admonition:: Description

        How to link to images in page templates in Plone.

.. contents :: :local:

Putting a static image into a page template
---------------------------------------------

Here is an example how to create <img> tag in .pt file::

        <img tal:attributes="src string:${context/@@plone_portal_state/portal_url}/++resource++plonetheme.mfabrik/close-icon.png" alt="[ X ]"/>
        
Let's break this down

* Obviosly we are rendering <img> tag

* src attribute is dynamically generated using TALES expression

* We use *string comprehension* to create src attribute. Alternative we could use e.g. *python:* protocol
  and embed one line python code to generate the attribute value.
  
* We look up a helper view called :doc:`plone_portal_state </misc/context>`. It is a
  BrowserView shipped with Plone and its purpose is to expose different helper methods
  to page templates and Python code.
  
* We call *plone_portal_state's* method ``portal_url()`` this will return the 
  root URL of our site. Note that this is not necessary the domain top level URL,
  as Plone sites can be nested in folders.
  
* We append our Zope 3 resource path to our site root URL (see below). This maps
  to some static media folder in our add-on files on the disk.

* There we point to *close-icon.png* image file.

* We also add <img> alt attribute normally. It is not dynamically generated.

When the page template is generated, the following snippet could look like::

::

        <img src="http://localhost:8080/mfabrik/++resource++plonetheme.mfabrik/logo.png" alt="[ X ]">

... or ... 

::

        <img src="http://mfabrik.com/++resource++plonetheme.mfabrik/logo.png" alt="[ X ]">

... depending of the site virtual hosting configuration.

Relative image look-ups
=======================

.. warning ::

        Do not never create relative image look-ups without prefixing the image source
        URL with the site root.
        
Hardcoded relative image path might seem to work::

        <img src="++resource++plonetheme.mfabrik/logo.png" >

...but this causes different image *base URL* on every page. The image URLs,
from the browser point of view, would be

::
        <img src="http://yoursite/++resource++plonetheme.mfabrik/logo.png" >

.. and then in another folder ....

::

        <img src="http://yoursite/folder/++resource++plonetheme.mfabrik/logo.png" >
              

... which **prevents browser to cache the image**.
              
Registering static media folders in your add-on product
---------------------------------------------------------

Zope 3 resource directory
=========================

Right way to put in a static image is for Zope 3 resource directory

* Create folder *yourcompany.product/yourcompany/product/browser/static*.

* Add the following ZCML to *yourcompany.product/yourcompany/product/browser/configure.zcml*.

.. code-block:: xml

    <browser:resourceDirectory
        name="yourcompany.product"
        directory="static"
        layer=".interfaces.IThemeSpecific"
        />

This will be picked up as ++resource++yourcompany.product/ static media path path.

Layer is optional: The static media path is available only 
when your add-on product is installed if the :doc:`layer </views/layers>` is specified.
        
Grok static media folder
========================      

This applies for add-on products using :doc:`five.grok </components/grok>` API.

Create folder yourcompany.product/yourcompany/product/static

This will be automatically picked up as ++resource++yourcompany.product/ static media path 
when Grok'ed add-on is launched

Rendering Image content items
--------------------------------------

You can refer to ATImage object's content data download by adding /image to URL::

        <img alt="" tal:attributes="src string:${context/getImage/absolute_url}/image" />
        
The magic is done in __bobo_traverse__ of ATImage by providing traversable hooks to access image download:

* http://svn.plone.org/svn/collective/Products.ATContentTypes/trunk/Products/ATContentTypes/content/image.py

Rendering ImageField 
-----------------------

Archetypes's ImageField maps its data to the content object at attribute which is the field's name.
If you have field 'campaignVideoThumbnail' you can make image tag by following ::

        <img class="thumbnail" tal:attributes="src string:${campaign/absolute_url}/campaignVideoThumbnail" alt="Campaign video" />

If you need more complex <img> output, create a helper function in your BrowserView and use Python code 
to perform the ImageField manipulation.

See ImageField for more information

* http://svn.plone.org/svn/archetypes/Products.Archetypes/trunk/Products/Archetypes/Field.py         

tag() method
-------------

.. note ::

        Using of tag() is discouraged. Create your image tags manually.

Some content provide handy tag() method to generate <img src="" /> tags
with different image sizes.

tag() is available in

* Archetypes ImageField

* ATNewsItem

* ATImage

* FSImage (Zope 2 image object in file-system)

tag() is defined in `OFS.Image <http://svn.zope.org/Zope/trunk/src/OFS/Image.py?rev=96262&view=auto>`_.

Scaling images
==============

tag() supports scaling. Scale sizes are predefined.
When ATImage is uploaded
various scaled versions of it are stored in the database.

Displaying a version of the image using scale "preview"

.. code-block:: python

	image.tag(scale="preview", alt="foobar text")

Will give out::

	<img src="http://something/folder/image/image_preview" alt="foobar text" />

.. note::

	If you are not using alt attribute you should always set it to
	empty string alt="". Otherwise screen readers will read
	the src attribute of the <img> aloud.

In order to simplify the accessing of these image scales, use `archetypes.fieldtraverser <http://pypi.python.org/pypi/archetypes.fieldtraverser>`_.
This package allows you to traverse to the stored image scales while still using AnnotationStorage and is a lot simpler to get going (in the author's humble opinion :).

Default scale names and sizes are defined in ImageField declaration for custom ImageFields.
For ATImage those are in `Products.ATContentTypes.content.image <http://svn.plone.org/svn/collective/Products.ATContentTypes/trunk/Products/ATContentTypes/content/image.py>`_.

