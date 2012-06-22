===========
Collections
===========

.. admonition:: Description

     Collections are site editor enabled searches.
     They provide automatic, folder like view, for the content fetched 
     from the Plone site by criteria defined by the site editor.

.. contents :: :local:

Introduction
------------

They are useful to generate different listings.

Collections are internally called "topics" and the corresponding
content type is "ATTopic". Collections were renamed from topics in 
Plone 3.0. In Plone 4.2, old style collections have been retired in favor of new style collections.

Collections searches is driven by two factors

* User visible "criteria" which is mapped to portal_catalog quries

* portal_catalog() indexes which you need to add yourself for custom content types.
  Read more about them in :doc:`Searching and Indexing chapter </searching_and_indexing/index>`

Adding new collection criteria (old style, < 4.2 only)
------------------------------------------------------

portal_catalog search indexes are not directly exposed to the collection
criteria management backend, since portal_catalog indices do not support
features like localization and user-friendly titles.

.. Note:: In Plone 4.2, the Collection section is no longer listed in Site Setup. But you can still access it here: http://localhost:8080/Plone/portal_atct/atct_manageTopicIndex.

New criteria can be created through-the-web in Site setup -> Collection section.
Click "All fields" to see unenabled portal_catalog criteria.
Later the edited settings can be exported to GenericSetup XML profile using
portal_setup tool (no need to create profile XMl files by hand).

portal_catalog indices can be added through-the-web on ZMI
portal_catalog tool tabs.

 
If you still want to create XML files by hand, read more about it in 
`Enable Collection Indices (fields for searching) for custom types HOW TO <http://plone.org/documentation/how-to/enable-collection-indices-fields-for-searching-for-custom-types>`_.

Sticky sorting
--------------

See 

* http://stackoverflow.com/questions/8791132/how-to-create-sticky-news-items-in-plone-4
