============
 Workflows
============

.. admonition:: Description

        Programming workflows in Plone.

.. contents :: :local:

Introduction
-------------

The DCWorkflow product manages the default Plone workflow system.

A workflow state is not directly stored on the object. Instead, a separate
portal_workflow tool must be used to access a workflow state. Workflow look-ups
involve an extra database fetch.

For more information, see 

* http://www.martinaspeli.net/articles/dcworkflows-hidden-gems

Creating workflows
------------------

The recommended method is to use the portal_workflow user interface in the Zope Management Interface
to construct the workflow through-the-web and then you can export it using GenericSetup's portal_setup tool.

Include necessary parts from exported workflows.xml and workflows folder in your add-on product
GenericSetup profile (add-on folder profiles/default).

Assigning the workflow to a particular content type
-----------------------------------------------------

This is done by workflows.xml. You can edit it online in portal_workflows in Zope Management Interface.

Getting the current workflow state
-----------------------------------

Example::

    workflowTool = getToolByName(self.portal, "portal_workflow")
    # Returns workflow state object
    status = workflowTool.getStatusOf("plone_workflow", object)
    # Plone workflows use variable called "review_state" to store state id
    # of the object state
    state = status["review_state"]
    assert state == "published", "Got state:" + str(state)

Filtering content item list by workflow state
-----------------------------------------------

Here is an example how to iterate through content item list
and let through only content items having certain state.

.. note ::

        Usually you don't want to do this, but use content
        aware folder listing method or portal_catalog query
        which does filtering by permission check.
        
Example::

    
        portal_workflow = getToolByName(self.context, "portal_workflow")
        
        # Get list of all objects
        all_objects = [ obj for obj in self.all_content if ISubjectGroup.providedBy(obj) or IFeaturedCourses.providedBy(obj) == True ]
      
        # Filter objects by workflow state (by hand)
        for obj in all_objects:
            status = portal_workflow.getStatusOf("plone_workflow", obj)
            if status and status.get("review_state", None) == "published":
                yield obj
        
     

Changing workflow state
-----------------------

You cannot directly set the workflow to any state, but you must push
it through legal state transitions.

**Security warning**: Workflows may have security assertations which are bypassed by admin user.
Always test your workflow methods using a normal user.

In Python code
================

Example how to publish content item ``banner``::

        from Products.CMFCore.WorkflowCore import WorkflowException
        
        workflowTool = getToolByName(banner, "portal_workflow")
        try:
            workflowTool.doActionFor(banner, "publish")
        except WorkflowException:
            # a workflow exception is risen if the state transition is not available
            # (the sampleProperty content is in a workflow state which
            # does not have a "submit" transition)
            logger.info("Could not publish:" + str(banner.getId()) + " already published?")
            pass
         

Example how to submit to review::

        from Products.CMFCore.WorkflowCore import WorkflowException
        
        portal.invokeFactory("SampleContent", id="sampleProperty")

        workflowTool = getToolByName(context, "portal_workflow")
        try:
            workflowTool.doActionFor(portal.sampleProperty, "submit")
        except WorkflowException:
            # a workflow exception is risen if the state transition is not available
            # (the sampleProperty content is in a workflow state which
            # does not have a "submit" transition)
            pass

Via HTTP
========

Plone provides a ``workflow_action`` script which is able to trigger the status
modification through an HTTP request (browser address bar).

Example::

	http://localhost:9020/site/page/content_status_modify?workflow_action=publish

Gets the list of ids of all installed workflows
------------------------------------------------

Useful to test if a particular workflow is installed::

  # Get all site workflows
  ids = workflowTool.getWorkflowIds()
  self.failUnless("link_workflow" in ids, "Had workflows " + str(ids))

Getting default workflow for a portal type
------------------------------------------

Get default workflow for the type::

 chain = workflowTool.getChainForPortalType(ExpensiveLink.portal_type)
 self.failUnless(chain == ("link_workflow",), "Had workflow chain" + str(chain))

Getting workflows for an object
-------------------------------

How to test which workflow the object has::

    # See that we have a right workflow in place
    workflowTool = getToolByName(context, "portal_workflow")
    # Returns tuple of all workflows assigned for a context object
    chain = workflowTool.getChainFor(context)

    # there must be only one workflow for our object
    self.failUnless(len(chain) == 1)

    # this must must be the workflow name
    self.failUnless(chain[0] == 'link_workflow', "Had workflow " + str(chain[0]))


Binding a workflow to a content type
--------------------------------------

Example with GenericSetup *workflows.xml*

.. code-block:: xml

    <?xml version="1.0"?>
    <object name="portal_workflow" meta_type="Plone Workflow Tool">
     <bindings>
       <type type_id="Image">
         <bound-workflow workflow_id="plone_workflow" />
       </type>
     </bindings>
    </object>

Updating security settings after binding workflow
--------------------------------------------------
Through the web this would be done by going to 
ZMI > portal_workflow > update security settings

To update security settings programmatically use the method updateRoleMappings.
The snippet below demonstrates this::

    from Products.CMFCore.utils import getToolByName
    # Do this after installing all workflows   
    wf_tool = getToolByName(self, 'portal_workflow')
    wf_tool.updateRoleMappings()

Disabling workflow for a content type
---------------------------------------

If a content type doesn't have a workflow it uses its parent container security settings.
By default, content types Image and File have no workflow.

Workflows can be disabled by setting the workflow setting empty in portal_workflow in ZMI.

Example how to do it with GenericSetup *workflows.xml*

.. code-block:: xml

        <?xml version="1.0"?>
        <object name="portal_workflow" meta_type="Plone Workflow Tool">
         <property
            name="title">Contains workflow definitions for your portal</property>
         <bindings>
          <!-- Bind nothing for these content types -->
          <type type_id="Image"/>
          <type type_id="File"/>
         </bindings>
        </object>

