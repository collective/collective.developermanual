-----------------------------------
Available permissions in Plone
-----------------------------------

.. admonition:: Description

        What Zope security permissions you have available for your Plone coding
        
.. contents :: local

Listing different available permissions
----------------------------------------

Each permission name is a string.

To see available permissions, click Security tab at your site root in Zope Management Interface.

In programming, use pseudoconstants instead of permission string values:

* See `CMFCore.permissions <http://svn.zope.org/Products.CMFCore/trunk/Products/CMFCore/permissions.py?rev=94487&view=markup>`_

* See `AccessControl.Permissions <http://svn.zope.org/Zope/trunk/src/AccessControl/Permissions.py?rev=96262&view=markup>`_

For available ZCML permission mappings see:

* `Products/Five/permissions.zcml <http://svn.zope.org/Zope/trunk/src/Products/Five/permissions.zcml?rev=99146&view=markup>`_

	* Permissions such as ``cmf.ModifyPortalContent``, ``zope2.View``

* `zope/security/permissions.zcml <http://svn.zope.org/zope.security/trunk/src/zope/security/permissions.zcml?rev=97988&view=markup>`_

	* ``zope.Public``

or search for the string ``<permission`` in ``*.zcml`` files in the *eggs*
folder of your Plone development deployment.

Example using UNIX grep tool:

.. code-block:: console

	grep -C 3 -Ri --include=*.zcml "<permission" *
	
Useful permissions
------------------

Permissions are shown by their verbose name in the :term:`ZMI`.

``List folder contents``
    This governs whether you can get a listing of the contents of a folder;
    it doesn't check whether you have the right to view the objects listed.
``View`` 
    This governs whether you are allowed to view some content.  
``Modify Portal Content``
    This governs whether you are allowed to modify some content.
``Access Contents Information``
    This permission allows access to an object, without necessarily viewing
    the object. For example, a user may want to see the object's title in a
    list of results, even though the user can't view the contents of that
    file.

More info:

* http://markmail.org/thread/3izsoh2ligthfcou
