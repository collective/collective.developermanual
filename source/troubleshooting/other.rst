=============================================
 Other troubleshooting
=============================================

.. admonition:: Description

    How to fix other miscellaneous problems with or concerning Plone 

.. contents :: :local:

Introduction
=============

This document contains information regarding how to fix other problems
that may arise through the usage of Plone.

Hyperlinks to authenticated Plone content in Microsoft Office 
=============================================================

Microsoft Office applications (in the first instance Word and Excel), have
been observed to attempt to resolve hyperlinks once clicked, prior to sending
the hyperlink to the user's browser.  So, if such a link points to some
Plone content that requires authentication, the Office application will 
request the URL first, and receive a 302 Redirect to the ``require_login`` 
Python script on the relevant Plone instance.  So, if your original hyperlink
was like so::

    http://example.com/myfolder/mycontent

and this URL requires authentication, then the Office application will send
your browser to this URL::

    http://example.com/acl_users/credentials_cookie_auth/require_login?came_from=http%3A//example.com/myfolder/mycontent

Normally, this isn't a problem if a user is logged out at the time. They will
be presented with the relevant login form and upon login, they will be 
redirected accordingly to the ``came_from=`` URL.

However, if the user is *already* logged in on the site, visiting this URL
will result in an ``Insufficient Privileges`` page being displayed.  This is
to be expected of Plone (as this URL is normally only reached if the given
user has no access), but because of Microsoft Office's mangling of the URL,
may not necessarily be correct as the user may indeed have access.

The following drop-in replacement for the ``require_login`` script has been
tested in Plone 4.1.3 (YMMV).  Upon a request coming into this script,
it attempts (a hack) to traverse to the given path. If permission is actually
allowed, Plone redirects the user back to the content. Otherwise, things
proceed normally and the user has no access (and is shown the appropriate
message)::

    ## Script (Python) "require_login"
    ##bind container=container
    ##bind context=context
    ##bind namespace=
    ##bind script=script
    ##bind subpath=traverse_subpath
    ##parameters=
    ##title=Login
    ##

    login = 'login'

    portal = context.portal_url.getPortalObject()
    # if cookie crumbler did a traverse instead of a redirect,
    # this would be the way to get the value of came_from
    #url = portal.getCurrentUrl()
    #context.REQUEST.set('came_from', url)

    if context.portal_membership.isAnonymousUser():
        return portal.restrictedTraverse(login)()
    else:
        expected_location = context.REQUEST.get('came_from')
        try:
            #XXX Attempt a traverse to the given path
            portal.restrictedTraverse(expected_location.replace(portal.absolute_url()+'/',''))
            container.REQUEST.RESPONSE.redirect(expected_location)
        except:
            return portal.restrictedTraverse('insufficient_privileges')()

For further reading see:

* http://plone.293351.n2.nabble.com/Linking-to-private-page-from-MS-Word-redirect-to-login-form-td5495131.html
* http://plone.293351.n2.nabble.com/Problem-with-links-to-files-stored-in-Plone-td3055014.html
* http://bytes.com/topic/asp-classic/answers/596062-hyperlinks-microsoft-applications-access-word-excel-etc
* https://community.jivesoftware.com/docs/DOC-32157

Why does ``folder_listing`` not list my contents?
====================================================

The site search settings (*Site Setup*--> *Search*) modifies the way
``folder_listing`` works.

So for example, if you specifify that you do not want to search objects
of type *Page*, they will not appear in ``folder_listing`` anymore.

From `this thread <http://lists.plone.org/pipermail/plone-product-developers/2012-March/thread.html#11436>`_.

