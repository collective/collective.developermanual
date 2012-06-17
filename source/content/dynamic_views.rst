====================
 Dynamic views
====================

.. contents :: :local:

.. admonition:: Description

	How to programmatically change the active view of a Plone content item

Introduction
------------

Dynamic views are views which the content editor can choose for his or
her content from the *Display...* drop down menu in the green edit frame.

By default, Plone comes with dynamic views for

* Folder listing

* Summary

* Photo album

* etc.

The default view can be also a content item picked from the folder.
Available content item types are controlled by 
``portal_properties -> site_properties -> default_page_types``.

More info

* http://stackoverflow.com/questions/9432229/enabling-folder-as-one-of-default-content-item-views

Permission for changing the view template of an item
=======================================================

A user needs the "Modify view template" permission to use the dynamic
view dropdown. If you want to restrict this ability, grant/revoke this
permission adequately.

This can be useful for some content-types like Dexterity ones, where
dynamic views are enabled by default, and the easiest way to disable
them is using this permission.


Default dynamic views
---------------------

Plone supports few dynamic views for folders out of the box

* Summary view (folder_summary_view)

* Tabular view (folder_tabular_view)

* Album view (atct_album_view)

* Listing (folder_listing)

* Full view (folder_full_view) 

These are defined in :doc:`portal_types information </content/types>`
for the *Folder* content type and mapped to the *Display* menu all
over in ZCML using ``browser:menuItem`` as described below.

Newly created folders have this dynamic view applied

* ``Products.CMFPlone/skins/plone_content/folder_summary_view.pt``
  (a non-view based old style Zope 2 page template)

More info

* :doc:`Overriding views </views/browserviews>` 

Creating a dynamic view
------------------------

Here are instructions how to create your own dynamic view.

There is also an example product `Listless view <https://github.com/miohtama/listlessview>`_,
which provides "no content listing" view for Folder content types.

Registering a dynamic view menu item
====================================

Your content type must support dynamic views

* The content type subclasses Products.CMFDynamicViewFTI.browserdefault.BrowserDefaultMixin

You need to register a dynamic view menu item with the corresponding
view in your configure.zcml:

.. code-block:: xml

  <browser:menuItem
        for="Products.ATContentTypes.interface.IATFolder"
        menu="plone_displayviews"
        title="Product listing"
        action="@@product_listing"
        description="List folder contents as product summary view"
        />
        
.. note ::

        Products.ATContentTypes uses non-standard name for "interfaces" package.
        There, it is "interface", while all other packages use "interfaces".         

The view must be listed in portal_types for the content type. In this
case, we should enable it for Archetypes folders using the following
GenericSetup XML *profiles/default/types/Folder.xml*.

Note that you don't need to copy the whole Folder.xml / Topic.xml from
Products/CMFPlone/profiles/default/types. Including the changed 
``view_methods`` in the XML code is enough.

You can also change this through portal_types in the ZMI.
    
.. note::

        view_methods must not have the @@view signature in their method name.

.. code-block:: xml

    <?xml version="1.0"?>
    <object name="Folder"
       meta_type="Factory-based Type Information with dynamic views"
       i18n:domain="plone" xmlns:i18n="http://xml.zope.org/namespaces/i18n">
         <property name="view_methods" purge="False">
           <!-- We retrofit these new views for Folders in portal_types info -->
           <element value="product_listing"/>

         </property>
    </object>

Also, if you want Collections to have this listing, you need to add
the following *profiles/default/types/Topic.xml*.

.. code-block:: xml

    <?xml version="1.0"?>
    <object name="Topic"
       meta_type="Factory-based Type Information with dynamic views"
       i18n:domain="plone" xmlns:i18n="http://xml.zope.org/namespaces/i18n">
     <property name="view_methods">
      <element value="folder_listing"/>
      <element value="folder_summary_view"/>
      <element value="folder_tabular_view"/>
      <element value="atct_album_view"/>
      <element value="atct_topic_view"/>

      <!-- We retrofit these new views for Folders in portal_types info -->
      <element value="product_listing"/>

     </property>
    </object>
    


Checking that your view is available
-------------------------------------

Products.CMFDynamicViewFTI.browserdefault.BrowserDefaultMixin.getAvailableLayouts() returns
the list of known layouts like following::

    [('folder_summary_view', 'Summary view'),
    ('folder_tabular_view', 'Tabular view'),
    ('atct_album_view', 'Thumbnail view'),
    ('folder_listing', 'Standard view'),
    ('product_listing', u'Product listing')]


.. code-block:: python

    layout_ids = [ id for id, title in self.portal.folder.getAvailableLayouts() ]
    self.assertTrue("product_list" in layout_ids)

Getting active layout
---------------------

.. code-block:: python

    >>> self.portal.folder.getLayout()
    'atct_album_view'


Changing default view programmatically
--------------------------------------

.. code-block:: python

    self.portal.folder.setLayout("product_listing")

Default page
------------

The default page is the **content** chosen to display when the visitor
arrives at a URL without any subpages or views selected.

This is useful if you are doing the folder listing manually and want
to filter out the default view.

The default_page helper view can be used to manipulate default pages.

Getting the default page

.. code-block:: python

    # Filter out default content
    container = self.getListingContainer()
    default_page_helper = getMultiAdapter((container, self.request), name='default_page')

    # Return content object which is the default page or None if not set
    default_page = default_page_helper.getDefaultPage(container)
    
Another example how to use this::

    from Products.CMFCore.interfaces import IFolderish

    def hasTabs(self):
        """
        Determine whether the page itself, or default page, in the case of folders, has setting showTabs set true.
        
        Show tab setting defined in dynamicpage.py.
        """

        
        page = self.context
        
        try:
            if IFolderish.providedBy(self.context):
                folder = self.context
                default_page_helper = getMultiAdapter((folder, self.request), name='default_page')
                page_name = default_page_helper.getDefaultPage(folder)
                page = folder[page_name]
        except:
            pass
                
        tabs = getattr(page, "showTabs", False)
                
        return tabs
            

Setting the default page can be done as simple as setting default_page
attribute of the folder to be the id of the default page:

.. code-block:: python

    folder.default_page = "my_content_id"

More information can be found in

* https://github.com/plone/plone.app.layout/tree/master/plone/app/layout/globals/context.py

* https://github.com/plone/plone.app.layout/tree/master/plone/app/layout/navigation/defaultpage.py

Setting a view using marker interfaces
--------------------------------------

If you need to have a view for few individual content items only, it
is best to do using marker interfaces.

* Register a view against a marker interface

* Assign this marker interface to a content item using the Zope
  Management Interface (ZMI)

For more info, see

* http://www.netsight.co.uk/blog/2010/5/21/setting-a-default-view-of-a-folder-in-plone

* :doc:`marker interfaces </components/interfaces>`


Migration script from default view to another
----------------------------------------------

Below is a script snippet which allows you to change the default view
for all folders to another type. You can execute the script through
the ZMI as a Python Script.

Script code::

        from StringIO import StringIO
        
        buf = StringIO()
        orignal='fancy_zoom_view'
        target='atct_album_view'
        for brain in context.portal_catalog(portal_type="Folder"):
                obj = brain.getObject()
                if getattr(obj, "layout", None) == orignal:
                        print >> buf, "Updated:" + obj.absolute_url()
                        obj.setLayout(target)
        return buf.getvalue()

This will allow you to migrate from ``collective.fancyzoom`` to Plone
4's default album view / Products.PipBox.

Method aliases
-----------------

Method aliases allow you to redirect basic actions (view, edit) to content type specific views.
Aliases are configured in portal_types.

Other resources
----------------

* http://blog.jphoude.qc.ca/2008/09/14/plone-changing-title-zope3-views/

* http://plone.org/documentation/how-to/how-to-create-and-set-a-custom-homepage-template-using-generic-setup

* `CMFDynamicView plone.org product page <http://plone.org/products/cmfdynamicviewfti/>`_
