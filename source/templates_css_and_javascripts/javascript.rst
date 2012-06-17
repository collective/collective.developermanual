==================
 Javascript
==================

.. admonition:: Description

        Writing, including and customizing Javascript for Plone add-ons

.. contents:: :local:

Introduction
------------

Javascripts files must be distributed to Plone

* By creating them through-the-web editor in :doc:`portal_skins </templates_css_and_javascripts/skin_layers>`. 
  are stored in ZODB in this case.
  
* By add-on products using :doc:`Zope 3 resource folders </templates_css_and_javascripts/resourcefolders>`

Then the Javascript must be registered on the site

* Through-the-web in portal_javascripts in ZMI

* Using :doc:`GenericSetup jsregistry.xml </components/genericsetup>` which
  is run (and rerun) when you use the add-on installer in the control panel  

Plone Javascripts are managed by resource registry *portal_javascripts*.
You can find this in Zope Management interface, under your portal root folder.

portal_javascript will automatically

* compress JS files

* merge JS load requests

* determine which files are included on which HTML page

* support IE conditional comments

Javascript basic tips
=================================

When using jQuery etc. libraries with Plone write your code so that you pass 
the library global reference to your script as a local - this way you can
include several library versions in one codebase.

.. code-block:: javascript

     (function($) {
          $(document).ready(function() {
                ... do stuff here ...
          })
     })(jQuery);

Always use DOM ready event before executing your DOM manipulation.

Don't include Javascript inline in HTML code unless you are passing variables from Python to Javascript.

Use JSLint with your code editor and ECMAStrict 5 strict mode to catch common Javascript mistakes (like missing var).

For more Javascript tips see `brief introduction to good Javascript practices and JSLint <http://opensourcehacker.com/2011/11/05/javascript-how-to-avoid-the-bad-parts/>`_ 

Plone default Javascript libraries
-------------------------------------

You can use any Javascript library with Plone
after inclusion it to JS registry (see below).

Plone 4.1 ships with jQuery and jQuery tools libraries.

`Plone and Javascript policies <http://plone.org/documentation/manual/developer-manual/client-side-functionality-javascript>`_.

`Plone compatible jQuery UI package <http://plone.org/products/collective.js.jqueryui>`_.

Creating Javascripts for Plone
------------------------------

The following ste

* Put ZMI -> portal_javascripts to debug mode

* Include new JS files 

        * Use ZCML configuration directive :doc:`resourceFolder </templates_css_and_javascripts/resourcefolders>` to
          include static media files in your add-on product
        
        * Put in new Javascript via ZMI upload (you can use Page Template type) to portal_skins/custom folder

* Register Javascript in portal_javascripts

        * Do it through-the-web using portal_javascripts ZMI user interface ...or...
        
        * Add *profiles/default/jsregistry.xml* file to describe Javascript files included with your add-on product 
       
Executing Javascript code on page load
--------------------------------------

Plone includes JQuery library which has ``ready()``
event handler to run Javascript code when DOM tree
loading is done (HTML is loaded, images and media files
are not necesssarily loaded).

Create following snippet::


    jq(document).ready(function() {
        // TODO: Execute your page manipulating Javascript code here
    });

Registering javascripts to portal_javascripts
---------------------------------------------

Javascript files need to be registered in order to appear in Plone's <html> <head>
and in the Javascript merge compositions.

Javascripts are registered to portal_javascripts tool using *profiles/default/jsregistry.xml* GenericSetup
profile file.

* `More information about jsregistry.xml <http://plone.org/documentation/manual/theme-reference/page/css/resource-registries/practical2>`_.

The following options are available

* *id* (required): URI from where the Javascript is loaded

* *expression* empty string or TAL condition which determintes whether the file is served to the user.
  The files with the same condition are grouped to the same compression bundle. For more information,
  see :doc:`expressions documentation </functionality/expressions>`.

* *authenticated* (Plone 4+) is expression override, which tells
  to load the script for authenticated users only

* *cookable* is merging of Javascript files allowed during the compression

* *inline* is script server as inline inside <script>...</script> tag

* *enabled* shortcut to disable some Javascripts

* *compression* none, safe or full. See full option list from portal_javascripts.

* *insert-before* and *insert-after* control the position of the Javascript file
  in relation to other served Javascript files

`Full description in the source code <https://github.com/plone/Products.ResourceRegistries/tree/master/Products/ResourceRegistries/exportimport/resourceregistry.py>`_.

Bundles
=======

There are several compressed Javascript bundles served by Plone.
The process of compressing & merging files to different bundles 
is internally called "cooking"

You can examine available bundles in *portal_javascripts*
Zope Management Interface Tool, on *Merged Compositions* tab.

Usually the following bundles are served 

* Anonymous users (no condition)

* Logged in users (condition: not: portal/portal_membership/isAnonymousUser)

* Visual editor (TinyMCE) related Javascripts

Include Javascript on every page
===================================

The following example includes Javascript file intended for anonymous site users.
It is included after toc.js so that the file ends up as the last script
of the compressed JS bundle which is served for all users.

The Javascript file itself is usually *yourcompany/app/static/yourjsfile.js*
in your :doc:`add-on product </tutorials/paste>`. 

It is mapped to URI like::

        http://localhost:8080/Plone/++resource++yourcompany.app/yourjsfile.js
        
by :doc:`Zope 3 resource subsystem </templates_css_and_javascripts/resourcefolders>`.

Example ``profiles/default/jsregistry.xml`` in your add-on product.

.. code-block:: xml

        <?xml version="1.0"?>
        <object name="portal_javascripts">
            <javascript
                id="++resource++plonetheme.xxx.scripts/cufon-yui.js"
                cacheable="True" compression="safe" cookable="True"
                enabled="True" expression=""  inline="False" insert-after="toc.js"/>
        </object>
        

.. note ::

        If <javascript> does not have insert-after or insert-before, the script will end up as the last
        of the Javascript registry.
                
Including Javascript for authenticated users only
=====================================================

The following registers two Javascript files which are aimed
to edit mode and authenticated users. The Javascript are 
added to the merge bundle and compressed, so they do not increase
the load time of the page. The files are loaded from ``portal_skins`` 
(not from resource folder) and can be referred by their direct filename -
Plone resolves portal_skins files magically for the site root and every 
folder.

``jsregistry.xml``:

.. code-block:: xml

        <?xml version="1.0"?>
        <object name="portal_javascripts">
        
        
                <javascript
                        id="json.js"
                        authenticated="True"
                        cacheable="True" compression="safe" cookable="True"
                        enabled="True" expression=""  inline="False" insert-after="tiny_mce.js"/>
                
                <javascript
                        id="orapicker.js"
                        authenticated="True"
                        cacheable="True" compression="safe" cookable="True"
                        enabled="True" expression=""  inline="False" insert-after="json.js"/>
        
        
        </object>

Including Javascripts for widgets and other special conditions 
=================================================================

Here is described a way to include Javascript for
certain widgets or certain pages only.

.. note ::

        Since Plone loads very heavy Javascripts for logged in users (TinyMCE),
        it often makes sense to decrease the count of HTTP requests and 
        just merge your custom scripts with this bundle instead of trying
        to have fine-tuned Javascript load conditions for rare cases.

* Javascripts are processed through portal_javascripts 

* A special condition is created in Python code to determine when to include the script or not

* Javascripts are served from a *static* media folder in 
  a Plone add-on utilizing Grok framework  

The example here shows how to include a Javascript
if the following conditions are met 

* Content type has a certain :doc:`Dexterity behavior </content/behaviors>` applied on it

* Different files are served for view and edit modes

.. note ::

        There is no easy way to currently directly check whether a certain 
        widget and widget mode is active on a particular view. Thus,
        we do some assumptions and checks manually.
        

jsregistry.xml:

.. code-block:: xml

        <?xml version="1.0"?>
        <object name="portal_javascripts">
        
                <!-- View mode javascript -->
                <javascript
                        id="++resource++yourcompany.app/integration.js"
                        authenticated="False"
                        cacheable="True" compression="safe" cookable="True"
                        enabled="True" expression="context/@@integration_javascript"  
                        inline="False" 
                        />
                
                <!-- Edit mode javascript -->
                <javascript
                        id="++resource++yourcompany.app/integration.edit.js"
                        authenticated="False"
                        cacheable="True" compression="safe" cookable="True"
                        enabled="True" expression="context/@@edit_integration_javascript"  
                        inline="False" 
                        />
        
        
        </object>

We create special conditions using :doc:`Grok </components/grok>` views.

.. code-block:: python

        # Zope imports
        from Acquisition import aq_inner
        from zope.interface import Interface
        from five import grok
        from zope.component import getMultiAdapter
        
        from yourcompany.app.behavior.lsmintegration import IYourWidgetIntegration
                
        class IntegrationJavascriptHelper(grok.CodeView):
            """ Used by portal_javascripts to determine when to include our 
                custom Javascript integration code.
                
            This view is referred from the expression in jsregistry.xml.         
            """
                
            # The view is available on every content item type
            grok.context(Interface)
            grok.name("integration_javascript")
            
            def render(self):
                """ Check if we are in a specific content type.
                
                Check that the Dexerity content type has a certain
                behavior set on it through Dexterity settings panel. 
                
                Alternative, just check for a marker interface here.
                """
                
                # The render() method is the only traversable 
                # Grok CodeView method. It can be used for rendering
                # HTML code, but also for utility views
                # to return raw Python data
                        
                try:
                    # Check if a Dexterity behavior is available on the current context object
                    # - if it is not, behavior adapter will raise TypeError
                    avail = IYourWidgetIntegration(self.context)
                except TypeError:
                    return False 
                
                # If called directly from the browser like 
                # http://localhost:8080/Plone/integration_javascript
                # will return HTTP 204 No Content
                
                return True
            
        class EditModeIntegrationJavascriptHelper(IntegrationJavascriptHelper):    
            """ Used by portal_javascripts to determine when to include our custom Javascript 
                integration code *on edit pages* only.
                
            Subclass the existing checked and add more limiting conditions.        
            """
            grok.name("edit_integration_javascript")
            
            def render(self):
                """
                @return True: If this template is rendered "Edit view" of the item
                """
                
                if not IntegrationJavascriptHelper.render(self):
                    # We are not even on the correct content type
                    return False 
        
                # This is a hacked together as Plone does not provide a real
                # mechanism to separate edit views to other views.
                # We simply check if the current view URI ends with "edit"
                
                path = self.request.get("PATH_INFO", "")
                        
                if path.endswith("/edit") or path.endswith("/@@edit"):
                    return True 
                
                return False

Passing dynamic settings to Javascripts
------------------------------------------

Passing settings on every page
================================

Here is described a way to pass data from site or context object to a Javascripts easily.
For each page, we create a ``<script>`` section which will include all the options
filled in by Python code.

We create the script tag in ``<head>`` section using a :doc:`Grok viewlet </views/viewlets>`
registered there.

viewlet.py::

        # -*- coding: utf-8 -*-
        """
            
            Viewlets related to application logic.
        
        """
        
        # Python imports
        import json
        
        # Zope imports
        from Acquisition import aq_inner
        from zope.interface import Interface
        from five import grok
        from zope.component import getMultiAdapter
        
        # Plone imports
        from plone.app.layout.viewlets.interfaces import IHtmlHead
                        
        # The viewlets in this file are rendered on every content item type
        grok.context(Interface)
        
        # Use templates directory to search for templates.
        grok.templatedir('templates')
        
        # The generated HTML snippet going to <head>
        TEMPLATE = u"""
        <script type="text/javascript" class="javascript-settings">
            var %(name)s = %(json)s;
        </script>
        """
        
        class JavascriptSettingsSnippet(grok.Viewlet):
            """ Include dynamic Javascript code in <head>. 
            
            Include some code in <head> section which initializes
            Javascript variables. Later this code can be used
            by various scripts.
            
            Useful for settings.
            """
            
            # This viewlet will be render()'ed in <head> section of Plone pages
            grok.viewletmanager(IHtmlHead)
            
            def getSettings(self):
                """ 
                @return: Python dictionary of settings 
                """
                
                context = aq_inner(self.context)
                portal_state = getMultiAdapter((context, self.request), name=u'plone_portal_state')
                
                # Create youroptions Javascript object and populate in these variables
                return {
                    # Pass dynamically allocated site URL to the Javascripts (virtual host monster thing)         
                    "staticMediaURL" : portal_state.portal_url() + "/++resource++yourcompany.app",
                    # Some other example parameters            
                    "schoolId" : 3,
                    "restService" : "http://yourserver.com:8080/rest"      
                }
            
        
            def render(self):
                """ 
                Render the settings as inline Javascript object in HTML <head>
                """
                settings = self.getSettings()
                json_snippet = json.dumps(settings)
                
                # Use Python string template facility to produce the code
                html = TEMPLATE % { "name" : "youroptions", "json" : json_snippet }
             
                return html


Passing settings on one page only
==================================

Here is an example like above, but is

* Specific to one view and this view provides the JSON code to populate the settings

* Settings are included using METAL slots instead of viewlets

.. code-block:: html

     <html xmlns="http://www.w3.org/1999/xhtml"
          xmlns:metal="http://xml.zope.org/namespaces/metal"
          xmlns:tal="http://xml.zope.org/namespaces/tal"
          xmlns:i18n="http://xml.zope.org/namespaces/i18n"
          metal:use-macro="context/main_template/macros/master">


        <metal:block fill-slot="javascript_head_slot">
            <script tal:replace="structure view/getSetupJavascript" />
        </metal:block>

.. code-block:: python

    class TranslatorMaster(grok.View):
        """ 
        Translate content to multiple languages on a single view.
        """

        def getJavascriptContextVars(self):
            """
            @return: Python dictionary of settings
            """

            state = getMultiAdapter((self.context, self.request), name="plone_portal_state")


            # Create youroptions Javascript object and populate in these variables
            return {
                # Javascript AJAX will call this view to populate the listing
                "jsonContentLister" : "%s/%s" % (state.portal_url(), getattr(JSONContentListing, "grokcore.component.directive.name"))
            }


        def getSetupJavascript(self):
            """
            Set some global helpers

            Generate Javascript code to set ``windows.silvupleOptions`` object from ``getJavascriptContextVars()``
            method output.
            """
            settings = self.getJavascriptContextVars()
            json_snippet = json.dumps(settings)

            # Use Python string template facility to produce the code
            html = SETTINGS_TEMPLATE % { "name" : "silvupleOptions", "json" : json_snippet }

            return html        



Useful out of the box Javascripts
----------------------------------

`Please read this blog post <http://www.sixfeetup.com/blog/2009/7/31/utilize-available-javascript-in-plone-without-knowing-javascript>`_.

Per folder overrides
---------------------

* http://pypi.python.org/pypi/Products.CustomOverrides

Generating Javascript dynamically
----------------------------------

TAL template language is not suitable for non-XML generation.
Use Python string templates. 

Don't put dynamically generated javascripts to ``portal_javascripts`` registry unless you want to cache them
and they do not differ by the user.

For example, see ``FacebookConnectJavascriptViewlet``

* http://svn.plone.org/svn/collective/mfabrik.like/trunk/mfabrik/like/viewlets.py

Conditional comments (IE)
------------------------------

* http://plone.org/products/plone/roadmap/232a

Upgrading jQuery
------------------

``jquery.js`` lives in *Products.CMFPlone* ``portal_skins/plone_3rdparty/jquery.js``.
Plone 4.1 ships with compressed jQuery 1.4.4.

Here are instructions to change jQuery version. Please note that this may
break Plone core functionality (tabs, overlays).

These instructions also apply if you want to enable debug version (non-compressed)
jQuery on your site.

* Download new jQuery from http://docs.jquery.com/Downloading_jQuery and save it to your local disk

* In ZMI, go to plone_3rdparty, customize jquery.js

* Upload new jQuery from your hard disk

Having multiple jQuery versions (noConflict)
-----------------------------------------------

* http://noenieto.com/blog/having-two-jquery-versions-in-one-plone


Loading Javascript files for certain edit views only (to be used with widgets)
------------------------------------------------------------------------------------

* http://stackoverflow.com/questions/5469844/registering-a-javascript-to-be-loaded-on-edit-view

AJAX-y view loading
-------------------

Loading by page load
======================

Let's imagine we have this piece of synchronous page template code.
The code is a :doc:`view page template </views/browserviews>` code which includes another view inside it.

.. code-block:: html

       <tal:finnish condition="python:context.restrictedTraverse('@@plone_portal_state').language() == 'fi'">
               <div tal:replace="structure here/productappreciation_view" />
       </tal:finnish>
       
To make it load the view asynchronous, to be loaded with AJAX call when the page loading has been completed, you can do:

.. code-block:: html
       
         <tal:finnish condition="python:context.restrictedTraverse('@@plone_portal_state').language() == 'fi'">
                
                                
                <div id="comment-placefolder">
                        
                        <!-- Display spinning AJAX indicator gif until our AJAX call completes -->
                        
                        <p class="loading-indicator">
                                <!-- Image is in Products.CMFPlone/skins/plone_images -->
                                <img tal:attributes="src string:${context/@@plone_portal_state/portal_url}/spinner.gif" /> Loading comments 
                        </p>
                        
                        <!-- Hidden link to a view URL which will render the view containing the snippet for comments -->                       
                        <a rel="nofollow" style="display:none" tal:attributes="href string:${context/absolute_url}/productappreciation_view" />
                        
                        <script>
                                
                                // Generate URL to ta view 
                                                        
                                jq(document).ready(function() {
                                        
                                        // Extract URL from HTML page
                                        var commentURL = jq("#comment-placefolder a").attr("href");
                                        
                                        if (commentURL) {
                                                // Trigger AJAX call
                                                jq("#comment-placefolder").load(commentURL);
                                        }
                                });                             
                        </script>
                </div>
                
Loading when element becomes visible
======================================

Here is another example where more page data is lazily loaded
when the user scrolls down to the page and the item becomes visible. 

.. code-block:: javascript
                                
        // Generate URL to ta view 
                                
        jq(document).ready(function() {
                
                // http://remysharp.com/2009/01/26/element-in-view-event-plugin/                                        
                jq("#comment-placeholder").bind("inview", function() {

                        // This function is executed when the placeholder becomes visible

                        // Extract URL from HTML page
                        var commentURL = jq("#comment-placeholder a").attr("href");
                                                                                                
                        if (commentURL) {
                                // Trigger AJAX call
                                jq("#comment-placeholder").load(commentURL);
                        }
                                                                
                });                                     
                
        });                             

More info

* http://blog.mfabrik.com/2011/03/09/lazily-load-elements-becoming-visible-using-jquery/

* http://remysharp.com/2009/01/26/element-in-view-event-plugin/

Checking if document is in WYSIWYG edit mode
----------------------------------------------

WYSIWYG editor (TinyMCE) is loaded in its own <iframe>.
Your UI related Javascript mode might want to do some special checks 
for running different code paths when the text is being edited.

Example:

.. code-block:: javascript

                // Check if we are in edit or view mode
                if(document.designMode.toLowerCase() == "on") {
                        // Edit mode document, do not tabify 
                        // but let the user create the content
                        return;
                } else {
                        kuputabs.collectTabs();         
                }

Image hovers
-----------------

Here is a simple jQuery method to enable image roll-over effects (hover).
This method is suitable for content editors who can only images through TinyMCE 
or normal upload - only naming image files specially is needed.
No CSS, Javascript or other knowledge needed by the person who needs
to add the images.

Just include this script on your HTML page and it will automatically
scan image filenames, detects image filenames with special roll-over marker
strings and then applies the roll-over effect on them. Roll-over
images are preloaded to avoid image blinking on slow connections.

The script

.. code-block:: javascript
        
        /**
         * Automatic image hover placement with jQuery
         * 
         * If image has -normal tag in it's filename assume there exist corresponding 
         * file with -hover in its name.
         * 
         * E.g. http://host.com/test_normal.gif -> http://host.com/test_hover.gif
         * 
         * This image is preloaded and shown when mouse is placed on the image.
         *
         * Copyright Mikko Ohtamaa 2011
         *
         * http://twitter.com/moo9000
         */
        
        (function (jQuery) {
                var $ = jQuery;
                        
                // Look for available images which have hover option
                function scanImages() {
                        $("img").each(function() {
                                
                                $this = $(this);
                                
                                var src = $this.attr("src");
                                
                                // Images might not have src attribute, if they
                                if(src) {
                                        
                                        // Detect if this image filename has hover marker bit
                                        if(src.indexOf("-normal") >= 0) {
                                                
                                                console.log("Found rollover:" + src);
                                                
                                                // Mangle new URL for over image based on orignal
                                                var hoverSrc = src.replace("-normal", "-hover");
                                                
                                                // Preload hover image
                                                var preload = new Image(hoverSrc);
                                                
                                                // Set event handlers
                                                
                                                $this.mouseover(function() {
                                                        this.src = hoverSrc;
                                                });
        
                                                $this.mouseout(function() {
                                                        this.src = src;
                                                });
        
                                        }
                                }
                        });             
                }
                
                $(document).ready(scanImages);
                
        })(jQuery);
        
        
Cross-Origin Resource Sharing (CORS) proxy view
--------------------------------------------------

Old web browsers do not support `Allow-acces-origin HTTP header <https://developer.mozilla.org/en/HTTP_access_control>`_
needed to do cross-domain AJAX requests (IE6, IE7).

Below is an example how to work around this for jQuery getJSON() calls by

* Detecting browsers which do not support this using jQuery.support API

* Doing an alternative code path through a local website proxy view which uses Python ``urllib``
  to make server-to-server call and return it as it would be a local call, thus 
  working around cross-domain restriction
  
This example is for Plone/Grok, but the code is easily port to other web frameworks.
  
.. note ::

        This is not a full example code. Basic Python and Javascript skills are needed
        to interpret and adapt the code for your use case.
          
Javascript example

.. code-block:: javascript

        /**
         * Call a RESTful service vie AJAX
         * 
         * The final URL is constructed by REST function name, based
         * on a base URL from the global settings.
         * 
         * If the browser does not support cross domain AJAX calls
         * we'll use a proxy function on the local server. For
         * performance reasons we do this only when absolutely needed.
         * 
         * @param {String} functionName REST function name to a call
         * 
         * @param {Object} Arguments as a dictionary like object, passed to remote call
         */
        function callRESTful(functionName, args, callback) {
                
            var src = myoptions.restService + "/" +functionName;
                    
            // set to true to do proxied request on every browser
            // useful if you want to use Firebug to debug your server-side proxy view
            var debug = false; 
            
                console.log("Doing remote call to:" + src)
                        
                // We use jQuery API to detect whether a browser supports cross domain AJAX calls
                // http://api.jquery.com/jQuery.support/
                if(!jQuery.support.cors || debug) {
                        // http://alexn.org/blog/2011/03/24/cross-domain-requests.html
                        // Opera 10 doesn't have this feature, neither do IExplorer < 8, Firefox < 3.5 
                        
                        console.log("Mangling getJSON to go through a local proxy")
                        
                        // Change getJSON to go to our proxy view on a local server
                        // and pass the orignal URL as a parameter
                        // The proxy view location is given as a global JS variable
                        args.url = src;
                        src = myoptions.portalUrl + "/@@proxy";                                
                }
                
                // Load data from the server
                $.getJSON(src, args, function(data) {                                          
                        // Parse incoming data and construct Table rows according to it
                        console.log("Data succesfully loaded");
                        callback(data, args);                                      
                                                
             });
                
        }  
  
The server-side view::
 
        
        import socket
        import urllib
        import urllib2
        from urllib2 import HTTPError

        from five import grok
        from Products.CMFCore.interfaces import ISiteRoot        
        from mysite.app import options

        
        class Proxy(grok.CodeView):
            """
            Pass a AJAX call to a remote server. This view is mainly indended to be used
            with jQuery.getJSON() requests.
            
            This will work around problems when a browser does not support Allow-Access-Origin HTTP header (IE).
            
            Asssuming only HTTP GET requests are made.s
            """  
            
            # This view is available only at the root of Plone site
            grok.context(ISiteRoot)
            
            
            def isAllowed(self, url):
                """
                Check whether we are allowed to call the target URL.
                
                This prevents using your service as an malicious proxy
                (to call any internet service).
                """     
                
                allowed_prefix = options.REST_SERVICE_URL   
                
                if url.startswith(allowed_prefix):
                    return True
                
                return False
                
            def render(self):
                """
                Use HTTP GET ``url`` query parameter for the target of the real request.
                """
                
                # Make sure any theming layer won't think this is HTML
                # http://stackoverflow.com/questions/477816/the-right-json-content-type
                self.request.response.setHeader("Content-type", "application/json")
                
                url = self.request.get("url", None)
                if not url:
                    self.request.response.setStatus(500, "url parameter missing")
                
                if not self.isAllowed(url):        
                    # The server understood the request, but is refusing to fulfill it. Authorization will not help and the request SHOULD NOT be repeate
                    self.request.response.setStatus(403, "proxying to the target URL not allowed")
                    return 
                
                # Pass other HTTP GET query parameters direclty to the target server
                params = {}
                for key, value in self.request.form.items():
                    if key != "url":
                        params[key] = value
                            
                # http://www.voidspace.org.uk/python/articles/urllib2.shtml
                data = urllib.urlencode(params)
                        
                full_url = url + "?" + data
                req = urllib2.Request(full_url)
        
                try:            
                    
                    # Important or if the remote server is slow
                    # all our web server threads get stuck here
                    # But this is UGLY as Python does not provide per-thread
                    # or per-socket timeouts thru urllib
                    orignal_timeout = socket.getdefaulttimeout()
                    try:
                        socket.setdefaulttimeout(10)
                                    
                        response = urllib2.urlopen(req)
                    finally:
                        # restore orignal timeoout
                        socket.setdefaulttimeout(orignal_timeout)
                        
                        
                    # XXX: How to stream respone through Zope
                    # AFAIK - we cannot do it currently
                                    
                    return response.read()
        
                except HTTPError, e:
                    # Have something more useful to log output as plain urllib exception
                    # using Python logging interface
                    # http://docs.python.org/library/logging.html
                    logger.error("Server did not return HTTP 200 when calling remote proxy URL:" + url)
                    for key, value in params.items():
                        logger.error(key + ": "  + value)
                    
                    # Print the server-side stack trace / error page
                    logger.error(e.read())
                                
                    raise e
                            
