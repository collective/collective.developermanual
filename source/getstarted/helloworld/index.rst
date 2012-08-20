==========================
 Hello World Tutorial
==========================

.. contents :: :local:

Introduction
-------------

You've installed Plone and now you want to extend it. Here's a simple Hello World tutorial to get you started. We'll create a new content-type, a custom view, and an add-on package to contain your changes.

The examples in this tutorial are pretty contrived, and probably wouldn't exist on a production site, but they serve our purpose well.


Assumptions
------------

You have:

- a buildout based Plone 4 installation running on port 8080, 
- ZopeSkel 2.21.2, 
- an understanding of Python basics,
- comfort working with the filesystem and command-line prompt

The Plone 4 Universal Installer currently provides ZopeSkel 2.21.2 (as of August 2012).

We will refer to the directory containing the buildout.cfg file as your **buildout directory**. If you used the universal installer, the buildout directory is usually called zintance or zeocluster. 

If you are on a Unix-like system, you can tail the event log to watch for any errors using something like ``tail -f var/log/instance.log`` from your buildout directory.

These examples should also work with Plone 3.


Create an add-on package
------------------------

Before extending Plone, you need to create an add-on package to hold your changes. We will use ZopeSkel to create a skeleton template for the project. For more information on ZopeSkel, see the section on :doc:`Bootstrapping Plone add-on development </getstarted/paste>`.

Projects stay in the src directory inside your buildout directory. 

#. First, change your working directory to the src directory of your buildout.::

     # from your buildout directory
     cd src
    

#. Create a project using ZopeSkel. This example creates an archetypes based project in a directory named example.helloworld.::

    ../bin/zopeskel archetype example.helloworld
    
#. ZopeSkel will ask you a series of questions. For now, you can use the defaults for Expert Mode and Version. Use ``Hello World`` for the Project Title. We will reference it in another step below.::

    Expert Mode? (What question mode would you like? (easy/expert/all)?) ['easy']: 
    Project Title (Title of the project) ['Example Name']: Hello World
    Version (Version number for project) ['1.0']: 
    Description (One-line description of the project) ['']: Simple Hello World Example
    
    
#. To use the code in your project, you'll need to add a reference to it in your buildout.cfg file. Add ``example.helloworld`` to the ``eggs`` section and ``src/example.helloworld`` to the ``develop`` section.::

    eggs =
        ...
        example.helloworld

    develop =
        src/example.helloworld

#. You need to rerun buildout for the changes to take effect.::

    # from your buildout directory
    ./bin/buildout
    
#. Then start or restart your Plone instance.::

    # from your buildout directory
    ./bin/instance start
    or
    ./bin/instance restart

    Note: If you are running ZEO instead of a stand-alone instance you'll need to use something like ./bin/client1 restart
    
#. Now, you should see your project in the Add-ons section of your Plone site. You can access the Add-ons section using an url like ``http://localhost:8080/Plone/prefs_install_products_form``. You can also access the Add-ons section by selecting ``Site Setup`` from the ``admin`` menu in the top right corner of your Plone site, then selecting ``Add-ons`` from the ``Site Setup`` page. 
On the Add-ons page, select the ``Hello World`` add-on and click on ``Activate``.

    .. image:: add-ons.png

Now that you have an add-on, you can use it to extend your Plone site.


Create a content-type
---------------------

The first thing we'll do is create a new content-type.

Plone comes with built-in content-types to cover most of the basics. Sometimes, you'll need something that isn't covered by the basics. You can extend an existing content-type, or create your own from scratch. In this example, we'll create a simple archetypes based content-type from scratch. 


#. First, we'll change our working directory to the project we created above.::

     # from your buildout directory
     cd src/example.helloworld

#. Use paster to create a content-type skeleton. Paster is included with ZopeSkel.::

    ../../bin/paster addcontent contenttype
    
#. Again, you'll be asked a series of questions. Use ``HelloWorld`` for the contenttype_name.::

    Enter contenttype_name (Content type name ) ['Example Type']: HelloWorld
    Enter contenttype_description (Content type description ) ['Description of the Example Type']: Simple Hello World Content Type
    Enter folderish (True/False: Content type is Folderish ) [False]: 
    Enter global_allow (True/False: Globally addable ) [True]: 
    Enter allow_discussion (True/False: Allow discussion ) [False]: 
    
This creates a few files, and edits some others. For our purposes, the most important one is ``helloworld.py`` contained in the ``src/example.helloworld/example/helloworld/content/`` directory. Open this file in your text editor.

Edit HelloWorldSchema inside this file so it looks like this.::

    HelloWorldSchema = schemata.ATContentTypeSchema.copy() + atapi.Schema((
    
        # -*- Your Archetypes field definitions here ... -*-
        atapi.StringField(
            name='first_name',
            required=True,
            widget=atapi.StringWidget(
                visible= {'view': 'visible', 'edit': 'visible'},
            ),
        ),
    
        atapi.StringField(
            name='last_name',
            required=True,
            widget=atapi.StringWidget(
                visible= {'view': 'visible', 'edit': 'visible'},
            ),
        ),
    
    
    ))
    
This adds two string attributes to our content-type; ``first_name`` and ``last_name``. They are required, and are visible on both the view and edit pages.

Restart your instance to have access to the new content-type.::

    # from your buildout directory
    ./bin/instance restart
    
To create a new object using the new content-type, select ``HelloWorld`` from the ``Add new...`` menu of your Plone site. This brings up the ``edit`` view.

    .. image:: helloworldobjectedit.png

Fill in the fields and click ``Save``. This brings up the ``view`` view.

    .. image:: helloworldobjectview.png

Notice the id of the object in the url. It is based on the Title of the object. It is all lower case, and spaces are turned into dashes. You'll need to select ``Publish`` from the ``State:`` menu so other folks can see the new object.

For more information about content in Plone, see the :doc:`Content management </content/index>` section of this manual. For more information about content types, see :doc:`Content Types </content/types>`.
    
Create a custom view
--------------------

In Plone, views are a way to create pages that display dynamic content. We'll create a view that checks whether an object has a ``first_name`` and ``last_name`` attribute, and displays ``Hello World`` or ``Hello <first_name> <last_name>`` as appropriate. Our view will be named ``hello_world``. We'll create 2 files and edit another.

#. Change our working directory to the ``browser`` directory.::

    # from the buildout directory
    cd src/example.helloworld/example/helloworld/browser


#. Edit configure.zcml to add an entry for our new view.::

    <configure
        xmlns="http://namespaces.zope.org/zope"
        xmlns:browser="http://namespaces.zope.org/browser"
        i18n_domain="example.helloworld">
    
      <include package="plone.app.contentmenu" />
    
      <!-- -*- extra stuff goes here -*- -->
        <browser:page
              for="*"
              name="hello_world"
              permission="zope2.Public"
              class=".hello_world.HelloWorld"
              />
    
    
    </configure>

The ``for`` line means our view can be used for any object. The ``name`` attribute is how we refer to the view. The ``permission`` attribute allows us to restrict permissions, although the ``zope2.Public`` permission allows anyone to see our view. The ``class`` attribute tells Plone to use the HelloWorld class in a file called hello_world.py when our view is called. We need to create that file and class. In the browser directory, create a file named ``hello_world.py`` and add the following::

    from Products.Five import BrowserView
    from Products.Five.browser.pagetemplatefile import ViewPageTemplateFile
    
    import logging
    logger=logging.getLogger("HelloWorld")
    
    class HelloWorld(BrowserView):
    
        template = ViewPageTemplateFile('hello_world.pt')
        
        def __call__(self):
            logger.info("HelloWorld: __call__: ")
            self.setup()
            return self.template()
            
        def setup(self):
            """"""
            logger.info("HelloWorld: setup: ")
            self.firstname = getattr(self.context, 'first_name', None)
            self.lastname = getattr(self.context, 'last_name', None)
        
Notice the class ``HelloWorld`` referenced in our configure.zcml entry. It contains a ``template`` attribute and two methods; ``__call__`` and ``setup``. The ``__call__`` method gets called when our view is accessed. It calls our ``setup`` method and returns the template. We are using the ``setup`` method to set some attributes that we will use in our view template. The file also includes some logging. These logging statements should show up in ``var/log/instance.log``.

We need to create the page template. In the browser directory, create a file named ``hello_world.pt`` and add the following::

    <html xmlns="http://www.w3.org/1999/xhtml"
          xmlns:metal="http://xml.zope.org/namespaces/metal"
          xmlns:tal="http://xml.zope.org/namespaces/tal"
          xmlns:i18n="http://xml.zope.org/namespaces/i18n"
          metal:use-macro="context/main_template/macros/master">
    
        <metal:block fill-slot="content-core">
            <div>
                <h1>Hello 
                    <span tal:condition="view/firstname | view/lastname">
                        <span tal:condition="view/firstname" tal:content="view/firstname">firstname</span>
                        <span tal:condition="view/lastname" tal:content="view/lastname">lastname</span>
                    </span>
                    <span tal:condition="not:view/firstname | view/lastname">World</span>
                </h1>
            </div>
        </metal:block>
    
    </html>

Plone uses Zope Page Templates. For more information about templating in Plone, see the :doc:`TAL page templates </templates_css_and_javascripts/template_basics>` section of this manual.

Plone includes a template called ``main_template``. We are taking advantage of it with the ``metal:use-macro="context/main_template/macros/master"`` line. It contains ``slots`` that we can fill. Anything inside the ``<metal:block fill-slot="content-core">`` and ``</metal:block>`` tags shows up in the ``content-core`` slot, which is beneath the description in the main content area of a page.

The ``tal:condition="view/firstname | view/lastname"`` declaration says only display the span if there is a ``firstname`` or ``lastname``. Then, we independently check whether ``firstname`` and ``lastname`` exist. If they do, we print them along with the word ``Hello``.

If ``firstname`` and ``lastname`` do not exist, we print ``Hello World``.

To use the view, add @@hello_world to the end of an object url in your plone site.::

    http://localhost:8080/Plone/a-hello-world-object/@@hello_world
    
Since our object has a ``firstname`` and ``lastname``, they are displayed along with the word ``Hello``.

    .. image:: hellojimbob.png

We can also call our view on the root of the site.::

    http://localhost:8080/Plone/@@hello_world

The root of the site does not have a firstname or lastname, so only ``Hello World`` is displayed.

    .. image:: helloworld.png

For a more in depth explanation of views, see the :doc:`Views and viewlets </views/index>` section of this manual.

To Do
-----

 - Add a section for creating a virtual env
 - Add a section for creating a plone 4 buildout with ZopeSkel
 - Put the code from the examples on Github as collective.hello_world
 - Change the examples from example.hello_world to collective.hello_world
 - General cleanup