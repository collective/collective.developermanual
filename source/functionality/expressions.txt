=============
Expressions
=============

.. admonition:: Description

        Expressions are one line long string templates or Python expressions
        which are used in various places on Plone for templates, action conditions
        and URL generation. 

.. contents :: :local:

Introduction
------------

Expressions are user or site-administration through-the-web-written conditions which can be evaluated.
You might want to use expressions in your own add-on product to provide user written conditions
for viewlet visibility, portlets, dynamic text, etc. Expressions are also used on TAL template language.

Expressions are used in

* ``tal:condition``, ``tal:content``, ``tal:replace``, ``tal:attribute``, ``tal:define`` TAL 
  template language directive content
  
* portal_css, portal_javascript and other resource manages to express when the resource should 
  be included or not
 
* portal_actions to define when content, site and user actions are visible  
       
Expression types
----------------
        
There are three main categories of expressions.

Expression can contain optional protocol: prefix to determine the expression type.

Default TALES expression
========================

Do :doc:`traversing </serving/traversing>` using slashes.

Example::

        context/getTitle        

string: expression
==================

Do string replace operation.

Example::

        string:${context/portal_url}/@@my_view_name

python: expression
==================

Evaluate as Python code.

Example::

    python:object.myFunction() == False             
        

Expression variables
------------------------------

Available expression variables are defined in CMFCore/Expressions.py::

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
        
You can also access :doc`helper views </misc/context>` directly by name.                
    
Using expression in your own code
---------------------------------

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
-------------------------------------

If you need to add complex Python code to your expression conditions it is best to put this code to BrowserView
and expose it as a method.

Then you can call view from TALES expression::
    
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

Register view normally using configure.zcml as "my_view_name".

You can use context interfaces like

* Products.CMFCore.interfaces.IContentish

*  zope.interface.Interface (or "*")

to make sure that this view is available on all content objects, as TALES will be evaluated
on every page, regarding on what kind of content the page wil present.

Expression examples
-------------------

Get current language
====================

Use :doc:`IPortalState context helper </misc/context>` view.

Example how to generate multilingual aware RSS feed link::

        string:${object/@@plone_portal_state/portal_url}/site-feed/RSS?set_language=${object/@@plone_portal_state/language} 

...or you can use Python expression for comparison::

        python:object.restrictedTraverse('@@plone_portal_state').language() == 'fi'
        
Check if object implements an interface
============================================

Example::

        python:context.restrictedTraverse('@@plone_interface_info').provides('Products.CMFCore.interfaces.IFolderish')            

Returns True or False. Useful for actions. 

Check if a certain hostname was used for HTTP request
========================================================

Example::

        python:"localhost" in request.environ.get("HTTP_HOST", "")
        
        
Check if the object is certain content type
==============================================

Example::

        python:getattr(object, "portal_type", "") == "Custom GeoLocation"