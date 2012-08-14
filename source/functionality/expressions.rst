=============
Expressions
=============

.. admonition:: Description

    Expressions are string templates or Python expressions
    which are used in various places in Plone for templates, action conditions
    and URL generation. 

.. contents:: :local:

Introduction
============

Expressions are part of :term:`TAL`, the Template Attribute Language.
They are used in Zope Page Templates (:term:`ZPT`) and
as part of workflow definitions, among other things.
You might want to use expressions in your own add-on product
to provide user-written conditions for viewlet visibility,
portlets, dynamic text, etc.

The authoritative reference is 
`Appendix C: Zope Page Templates Reference <http://docs.zope.org/zope2/zope2book/AppendixC.html>`_
of the `Zope 2 Book <http://docs.zope.org/zope2/zope2book/index.html>`_

Expressions are used in:

* the ``tal:condition``, ``tal:content``, ``tal:replace``,
  ``tal:attribute``, ``tal:define`` :term:`TAL` directives;
  
* ``portal_css``, ``portal_javascript`` and other resource managers, to
  express when a resource should be included or not;
 
* ``portal_actions`` to define when content, site and user actions are
  visible.
       
Expression types
================
        
There are three main categories of expressions.

Expression can contain an optional ``protocol:`` prefix
to determine the expression type.

path expression (default)
--------------------------

Unless you specify expression type using ``python:`` or ``string:`` notation
a `path expression <http://docs.zope.org/zope2/zope2book/AppendixC.html#tales-path-expressions>`_
is assumed.

Path expressions use slashes for traversal 
(:doc:`traversing </serving/traversing>`),
and will implicitly call callables.

Example: call the ``Title()`` method of the ``context`` object
and return its value::
 
    context/Title        

Variables can be included using ``?``.
Example: access a folder using the id stored in the ``myItemId`` variable,
and return its title::

        context/?myItemId/Title

.. Note::

    With this kind of usage, if the variable you're dereferencing isn't
    sanitized, there could be security ramifications. Use 
    ``python:restrictedTraverse()`` instead if you need to use
    variables in your path parts.

``string:`` expressions
-------------------------

Do string replace operation.

Example::

        string:${context/portal_url}/@@my_view_name

``python:`` expression
------------------------

Evaluate as Python code.

Example::

    python:object.myFunction() == False             
        

Expression variables
==============================

Available expression variables are defined in ``CMFCore/Expressions.py``::

    data = {
        'object_url':   object_url,
        'folder_url':   folder.absolute_url(),
        'portal_url':   portal.absolute_url(),
        'object':       object,
        'folder':       folder,
        'portal':       portal,
        'nothing':      None,
        'request':      getattr(portal, 'REQUEST', None),
        'modules':      SecureModuleImporter,
        'member':       member,
        'here':         object,
        }
        
You can also access :doc:`helper views </misc/context>` directly by name.
    
Using expressions in your own code
===================================

Expressions are persistent objects. You usually
want to attach them to something, but this is not necessary.

Example::

	from Products.CMFCore.Expression import Expression, getExprContext
	
	# Create a sample expression - usually this is taken from
	# the user input
	expression = Expression("python:context.Title() == 'foo')
	
	expression_context = getExprContext(self.context)  
	
	# Evaluate expression by calling
	# Expression.__call__(). This
	# will return whatever value expression evaluation gives
	value = expression(expression_context)
	
	if value.strip() == "":
		# Usually empty expression field means that
		# expression should be True
		value = True
	
	if value:
		# Expression succeeded
		pass
	else:
		pass
		
    
Custom expression using a helper view
=====================================

If you need to add complex Python code to your expression conditions
it is best to put this code in a BrowserView
and expose it as a method.

Then you can call the method on a view from a TALES expression::
    
    object/@@my_view_name/my_method

Your view code would look like::

    class MyViewName(BrowserView):
        """ Exposes methods for expression conditions """ 
            
        def my_method(self):
            """ Funky condition 
            
            self.context = object for which this view was traversed
            """
            if self.context.Title().startswith("a"):
                return True
            else:
                return False

Register the view as "my_view_name", using ``configure.zcml`` as usual.

You can use context interfaces like

* ``Products.CMFCore.interfaces.IContentish``

*  ``zope.interface.Interface`` (or ``*``)

to make sure that this view is available on all content objects,
as TALES will be evaluated on every page,
depending on what kind of content the page will present.

Expression examples
===================

Get current language
--------------------

Use :doc:`IPortalState context helper </misc/context>` view.

Example how to generate a multilingual-aware RSS feed link::

    string:${object/@@plone_portal_state/portal_url}/site-feed/RSS?set_language=${object/@@plone_portal_state/language} 

... or you can use a Python expression for comparison::

    python:object.restrictedTraverse('@@plone_portal_state').language() == 'fi'

Check current language in TAL page template
----------------------------------------------

If you need to have HTML code, e.g. links, conditioned by a langauge in templates

Example::

	<a tal:define="language context/@@plone_portal_state/language" tal:condition="python: language == 'fi'"
           href="http://www.fi">Finnish link</a>
           
Example to have different footers (or something similar) for different languages::
    <div tal:replace="structure context/footertext"  tal:condition="python:context.restrictedTraverse('@@plone_portal_state').language() == 'no'" /> 
    <div tal:replace="structure context/footertexteng"  tal:condition="python:context.restrictedTraverse('@@plone_portal_state').language() == 'en'" />


Check if object implements an interface
--------------------------------------------

Example::

    python:context.restrictedTraverse('@@plone_interface_info').provides('Products.CMFCore.interfaces.IFolderish')            

Returns ``True`` or ``False``. Useful for actions. 

Check if a certain hostname was used for HTTP request
--------------------------------------------------------

Example::

    python:"localhost" in request.environ.get("HTTP_HOST", "")


Check if the object is certain content type
----------------------------------------------

Example::

    python:getattr(object, "portal_type", "") == "Custom GeoLocation"


Get portal description
----------------------

Example::

    tal:define="
            portal context/portal_url/getPortalObject;
            portal_description portal/Description"
