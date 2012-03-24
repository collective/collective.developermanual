============================
 Context helpers
============================

.. contents :: :local:

Introduction
------------

This document tells how to access view and context utilities in Plone.

IPortalState and IContextState
------------------------------

IPortalState define IContextState view-like interfaces
to access miscencancellous information useful for the
current page render. The views are cached properly,
so they should access the information quite effective manner

* IPortalState is mapped as *@@plone_portal_state* view for traversing.

* IContextState is mapped as *@@plone_context_state* view for traversing.

To see what's available through the interface,
read documentation in
`plone.app.layout.globals.interfaces <http://svn.plone.org/svn/plone/plone.app.layout/trunk/plone/app/layout/globals/interfaces.py>`_
module.

Example how to get portal root URL::

    from Acquisition import aq_inner
    from zope.component import getMultiAdapter

    ...
    
    class MyView(BrowserView):

        ...
        
        def mymethod(self):
            context = aq_inner(self.context)
            portal_state = getMultiAdapter((context, self.request), name=u'plone_portal_state')
        
            url = portal_state.portal_url()


Example how to get the current language::

    from Acquisition import aq_inner
    from zope.component import getMultiAdapter

    ...

    context = aq_inner(self.context)
    portal_state = getMultiAdapter((context, self.request), name=u'plone_portal_state')

    current_language = portal_state.language()

Example how to expose portal_state to template:

ZCML includes allowed_attributes::

    <browser:page
        for="*"
        name="test"
        permission="zope2.Public"
        class=".views.MyView"
        allowed_attributes="portal_state"
        />

Python class exposes the variable::

    from Acquisition import aq_inner
    from zope.component import getMultiAdapter

    class MyView(BrowserView):

        @property
        def portal_state(self):
            context = aq_inner(self.context)
            portal_state = getMultiAdapter((context, self.request), name=u'plone_portal_state')
            return portal_state

Template can use it::

    <div>
        The language is <span tal:content="view/portal_state/language" />
    </div>

You can directly look up portal_state in template using acquisition
magic and view traversing, without need of ZCML code
or Python view code changes. This is useful e.g. overridden
viewlet templates::

    <!--

        In traversing @@ marks that the traversing
        machine should look up a view by that name.

        First we look up the view and then use
        it to access the variables defined in
        IPortalState interface.

    -->

    <div tal:define="portal_state context/@@plone_portal_state" >
        The language is <span tal:content="portal_state/language" />
    </div>
    
Using in templates and expressions
----------------------------------

You can use IContextState and IPortalState in TALES expressions, like portal_actions too.

Example portal_actions condition expression::

        python:object.restrictedTraverse('@@plone_portal_state').language() == 'fi'    


Tools
-----

Tools are persistent utility classes available in the site root.
They are visible in ZMI. Tools include things like

* portal_catalog - Search and indexing facilities for content

* portal_workflow - Inquiry and do workflow related actions

* portal_membership - User registration information

ITools interface
++++++++++++++++

`plone.app.layout.globals.interfaces.ITools interface <https://svn.plone.org/svn/plone/plone.app.layout/trunk/plone/app/layout/globals/interfaces.py>`_
and Tools BrowserView provide cached access for most often
needed tools.

ITools is mapped as *plone_tools* view for traversing.

Example::

    from Acquisition import aq_inner
    from zope.component import getMultiAdapter

    context = aq_inner(self.context)
    tools = getMultiAdapter((context, self.request), name=u'plone_tools')

    portal_url = tools.url()

    # The root URL of the site is got by using portal_url.__call__()
    # method

    the_current_root_url_of_the_site = portal_url()



getToolByName
+++++++++++++

getToolByName is old-fashioned way of getting tools the context
object as a start point. It also works for tools
which are not defined in ITools interface.

getToolByName gets any Plone portal root item using acquisition.

Example::

    from Products.CMFCore.WorkflowCore import WorkflowException

    # Do the workflow transition "submit" for the current context
    workflowTool = getToolByName(self.context, "portal_workflow")
    workflowTool.doActionFor(self.context, "submit")

getSite
+++++++

sometimes you don't have a context and/or you just need to get the portal object (site root)::

    from zope.app.component.hooks import getSite
    portal = getSite()