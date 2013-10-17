=============
 Local roles
=============

.. admonition:: Description

    Creating and setting local roles of Plone members programmatically.

.. contents:: :local:

Introduction
=============

Local roles allows user accounts to have special privileges
for a folder and its children.

By default Plone has roles like ``Contributor``, ``Reader``, ``Editor``, etc.
and you can view these on the :guilabel:`Sharing` tab
and in :term:`ZMI` :guilabel:`Security` tab.

Good introduction to roles:
`Basic Roles and Permissions in Plone <http://www.sixfeetup.com/blog/basic-roles-and-permissions-in-plone>`_

Creating a new role
=======================

New Plone roles can be created through the 
:doc:`GenericSetup rolemap.xml </components/genericsetup>` file.

Example ``profiles/default/rolemap.xml``

.. code-block:: xml

    <?xml version="1.0"?>
    <rolemap>
      <roles>
        <role name="National Coordinator"/>
        <role name="Sits Manager"/>
      </roles>
      <permissions>
      </permissions>
    </rolemap>


.. Note::

    By default, user-defined roles will appear only in the ZMI.
    If you want them to appear on the Sharing tab
    please see the links below.

More info

* http://encolpe.wordpress.com/2010/02/08/add-a-new-role-in-the-sharing-tab-for-plone-3/

* http://plone.org/documentation/manual/developer-manual/generic-setup/reference/roles-and-permissions

* http://pypi.python.org/pypi/collective.sharingroles

Setting local role
===================

``manage_setLocalRoles`` is defined in `AccessControl.Role.RoleManager <http://svn.zope.org/Zope/trunk/src/AccessControl/Role.py?rev=96262&view=markup>`_.

Example::

    context.manage_setLocalRoles(userid, ["Local roles as a list"])

Getting local roles
===================

The ``get_local_roles()`` method returns currently-set local roles.
This does not return all the *effective* roles 
(which may include roles acquired from the parent hierarchy).
``get_local_roles_for_userid()`` returns roles for a particular user as a tuple.

Example::

    # get_local_roles() return sequence like ( ("userid1", ("rolename1", "rolename2")), ("userid2", ("rolename1") )
    roles = context.get_local_roles()

Deleting local roles
====================

``manage_delLocalRoles(userids)`` takes a *list of usernames* as argument.
All local roles for these users will be cleared.

The following example (``membrane``-specific)
will reset local roles based on external input ::

    def _updateLocalRoles(self):
        """ Resets Local Coordinator roles for associated users.

        Reads Archetypes field which is a ReferenceField to membrane users.
        Based on this field values users are granted local roles on this object.
        """

        # Build list of associated usernames
        usernames = []

        # Set roles for newly given users
        for member in self.getExtraLocalCoordinators():

            # We are only interested in this particular custom membrane user type
            if member.getUserType() == "local_coordinator":

                username = member.getUserName()

                usernames.append(username)

                self.manage_setLocalRoles(username, ["Local Coordinator"])

        membrane = getToolByName(self, "membrane_tool")

        # Make sure that users which do not appear in extraLocalCoordinators
        # will have their roles cleared
        for username, roles in self.get_local_roles():

            sits_user = membrane.getUserAuthProvider(username)

            if not username in usernames:
                print "Clearing:" + username
                self.manage_delLocalRoles([username])

Local role caching
==================

Resolving effective local roles is a cumbersome operation, so the result is cached.

.. warning::
    **Unit testers**: Local roles are cached per request.
    You need to clear this cache after modifying an object's local roles
    or switching user if you want to get proper readings.

Unit test example method::

    def clearLocalRolesCache(self):
        """ Clear borg.localroles cache.

        borg.localroles check role implementation caches user/request combinations.
        If we edit the roles for a user we need to clear this cache,
        """
        from zope.annotation.interfaces import IAnnotations
        ann = IAnnotations(self.app.REQUEST)
        for key in ann.keys(): # Little destructive here, deletes *all* annotations
            del ann[key]

Debugging
=========

Set your breakpoint in ``Products.PlonePAS.plugins.local_role.LocalRolesManager.getRolesInContext()``
and ``Products.PlonePAS.plugins.role.GroupAwareRoleManager.getRolesForPrincipal()``.
There you see how roles for a given context are being resolved.

Check the ``acl_users.portal_role_manager`` tool via the :term:`ZMI`.

Please see the `zopyx.plone.cassandra <http://pypi.python.org/pypi/zopyx.plone.cassandra>`_ add-on product.

Other
-----

* http://toutpt.wordpress.com/2009/03/14/plone-and-local-roles-too-quiet/
