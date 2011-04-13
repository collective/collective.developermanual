====================
 Import and export
====================

.. admonition:: Description

        Importing and exporting content between Plone sites and other CMS sysstems

.. contents :: local

Introduction
------------

Goal: you want to import and export content between Plone sites.

* If both sites have identical version and add-on product configuration you can use Zope Management Interface export/import

* If they don't and you e.g. have different Plone version on source and target site, you need to use add-on product like `quintagroup.transmogrifier <http://projects.quintagroup.com/products/wiki/quintagroup.transmogrifier>`_

quintagroup.transmogrifier
--------------------------

`quintagroup.transmogrifier <http://projects.quintagroup.com/products/wiki/quintagroup.transmogrifier>`_ is an add-on product which provides Plone adminstrator user interface for
exporting and importing content.

Internally, it uses `collective.transmogrifier <http://pypi.python.org/pypi/collective.transmogrifier>`_ package which itself does not provide any kind of user interface.

`Transmogrifier <http://pypi.python.org/pypi/collective.transmogrifier>`_ is a tool which serializes and deserializes content based o
n pipelines. Pipelines are written in .ini-like plain text file based file format and they consists
of sections.  
Blueprints are self-contained reusable components which can be recycled between different content migration pocesses.
Section is based on a blueprint and defines some configurable parameters for this blueprint.

Exporting single folder only
============================

Here is explained how to export and import `Plone CMS <http://plone.org>`_
folders between different Plonen versions, or 
different CMS systems, using  XML based content marshalling and 
`quintagroup.transmogrifier <http://projects.quintagroup.com/products/wiki/quintagroup.transmogrifier>`_.

This overcomes some problems with Zope management based export/import which uses `Python pickles
<http://docs.python.org/library/pickle.html>`_ and thus needs identical codebase on the source 
and target site. Exporting and importing between Plone 3 and Plone 4 is possible.

You can limit export to cover source content to with arbitary :doc:`portal_catalog </searching_and_indexing/query>` conditions.
If you limit source content by path you can effectively export single folder only.

The recipe described here assumes the exported and imported site have the same path for the folder.
Manually rename or move the folder on source or target to change its location.

.. note ::

        The instructions here requires quintagroup.transmogrify version 0.4 or later.

Source site
+++++++++++

Execute these actions on the source Plone site.

Install ``quintagroup.transmogrifier`` via buildout and Plone add-on control panel.

Go to *Site setup* > *Content migration*.

Edit export settings. Remove unnecessary pipeline entries by looking the example below. Add a new ``catalogsource`` blueprint.
The ``exclude-contained`` option makes sure we do not export unnecessary items from the parent folders::
    
        [transmogrifier]
        pipeline =
            catalogsource
            fileexporter
            marshaller
            datacorrector
            writer
            EXPORTING
        
        [catalogsource]
        blueprint = quintagroup.transmogrifier.catalogsource
        path = query= /isleofback/ohjeet
        exclude-contained = true
        
Also we need to include some field-level exluding bits for the folders, because the target site does not necessary
have the same content types available as the source site and this may prevent
setting up folderish content settings::

        [marshaller]
        blueprint = quintagroup.transmogrifier.marshaller
        exclude = 
          immediatelyAddableTypes
          locallyAllowedTypes
            
You might want to remove other, unneeded blueprints from the export ``pipeline``.
For example, ``portletexporter`` may cause problems if the source and target site
do not have the same portlet code.
        
Go to *Zope Management Interface* > *portal_setup* > *Export* tab. Check Content (transmogrifier) step.
Press *Export Selected Steps* at the bottom of the page. Now a .tar.gz file will be downloaded.    

During the export process ``instance.log`` file is updated with status info. You might want to follow
it in real-time from UNIX command line

.. code-block:: console

        tail -f var/log/instance.log 

In log you should see entries running like::

        2010-12-27 12:05:30 INFO EXPORTING _path=sisalto/ohjeet/yritys/yritysten-tuotetiedot/tuotekortti
        2010-12-27 12:05:30 INFO EXPORTING 
        Pipeline processing time: 00:00:02
                  94 items were generated in source sections
                  94 went through full pipeline
                   0 were discarded in some section

Target site
+++++++++++

Execute these actions on the target Plone site.

Install ``quintagroup.transmogrifier`` via buildout and Plone add-on control panel.

Open target site ``instance.log`` file for monitoring the import process

.. code-block:: console

        tail -f var/log/instance.log 

Go to *Zope Management Interface* > *portal_setup* > *Import* tab. 

Choose downloaded ``setup_toolxxx.tar.gz`` file at the bottom of the page,
for *Import uploaded tarball* input.

Run import and monitoring log file for possible errors. Note that the import
completes even if the target site would not able to process incoming content.
If there is a serious problem the import seems to complete succesfully,
but no content is created.

.. note ::

       Currently export/import is not perfect. For example, ZMI content type icons  are currently
       lost in the process. It is recommended to do a test run on a staging server
       before doing this process on a production server.
       Also, the item order in the folder is being lost.                 

More information
++++++++++++++++

* :doc:`How to perform portal_catalog queries </searching_and_indexing/query>`

* http://webteam.medsci.ox.ac.uk/integrators-developers/transmogrifier-i-want-to-.../

* https://svn.plone.org/svn/collective/quintagroup.transmogrifier/trunk/quintagroup/transmogrifier/catalogsource.py

Fast content import
-------------------

* See `this blog post <http://blog.redturtle.it/redturtle-blog/fast-content-import>`_