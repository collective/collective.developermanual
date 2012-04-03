===============
 Views
===============

.. admonition:: Description

    Rendering HTML pages in Plone using Zope 3 view pattern.

.. contents:: :local:

Introduction
=============

Plone/Zope uses a *view* pattern to output dynamically generated HTML pages.

*Views* are the basic elements of modern Python web frameworks. A view runs
code to setup Python variables for a rendering template. Output is not
limited to HTML pages and snippets, but may contain JSON, file download
payloads, or other data formats.

Views are usually a combination of a:

* Python class, which performs the user interface logic setup, and a
* corresponding :term:`ZPT` page template, or direct Python string output.

By keeping as much of the view logic in a separate Python class as we
can and making the page template as simple as possible, better component
readability and reuse is achieved. You can override the Python logic
or the template file, or both.

When you are working with Plone, the most usual view type is ``BrowserView``
from the ``Products.Five`` package, but there are others.

Each ``BrowserView`` class is a Python callable. The
``BrowserView.__call__()`` method acts as an entry point to executing the
view code. From Zope's point of view, even a function would be sufficient,
as it is a callable.

Plain Zope 3 vs. Grok
---------------------

Views were introduced in Zope 3 and made available in Plone by way of
the ``Products.Five`` package, which provides some Plone/Zope 2 specific
adaption hooks to the modern Zope 3 code base.  However, Zope 3's way
of XML-based configuration using :term:`ZCML` and separating things to three
different files (Python module, ZCML configuration, TAL template) was
later seen as cumbersome.

Later, a project called `Grok <http://grok.zope.org/>`_ was started to
introduce an easy API to Zope 3, including a way of how to set up and
maintain views. For more information about how to use Grok (found in
the ``five.grok`` package) with Plone, please read the `Plone and Grok
tutorial
<http://plone.org/products/dexterity/documentation/manual/five.grok>`_.

.. note:: At the time of writing (Q1/2010), all project templates in Paster
   still use old-style Zope views.

More information
----------------

* `Zope view tutorial <http://plone.org/documentation/tutorial/borg/zope-3-views>`_.

* `Grok view tutorial <http://plone.org/products/dexterity/documentation/manual/five.grok/browser-components/views>`_.

View components
---------------

Views are Zope component architecture multi-adapter registrations.  If you
are doing manual view look-ups, then this information is relevant to you.

Views are looked up by name. The Zope publisher always does a view lookup,
instead of traversing, if the traversing name is prefixed with ``@@``.

Views are resolved against different interfaces:

* *context*: Any class/interface. If not given, ``zope.interface.Interface``
  is used (corresponds to a registration ``for="*"``).

* *request*: The current HTTP request. Interface
  ``zope.publisher.interfaces.browser.IBrowserRequest`` is used.

* *layer*: Theme layer interface. If not given,
  ``zope.publisher.interfaces.browser.IDefaultBrowserLayer`` is used.

See also `related source code
<http://svn.zope.org/zope.browserpage/trunk/src/zope/browserpage/metaconfigure.py?rev=103273&view=auto>`_.

Customizing views
===========================

To customize existing Plone core or add-on views you:

* usually override the related page template file (``.pt``)

* sometimes you need to change related Python view class code also and in
  this case you override the Python class by using your own add-on which
  installs a view class replacement using add-on layer.

Overriding view template
--------------------------

Follow instructions how to :doc:`use z3c.jbot <templates_css_and_javascripts/template_basics> to override templates`.

Overriding view class
------------------------

Here is a short introduction on finding how existing views are defined.
First, you go to ``portal_types`` to see what views have been registered to
a particular content type.

For example, if you want to override *Folder's* Tabular view, you find out
that it is registered as the handler for ``/folder_tabular_view``.

You look for ``folder_tabular_view`` old style page templates or
``@@folder_tabular_view`` BrowserView ZCML registrations in the Plone
source tree - it can be either.

Example how to search for this using UNIX tools:

.. code-block:: console

    find . | grep -i folder_tabular_view # find old style .pt files
    grep -Ri --include="\*.zcml" folder_tabular_view * # find new style view registrations in ZCML files

The ``folder_tabular_view`` is found in :doc:`skin layer </templates_css_and_javascripts/skin_layers>`
called ``plone_content`` in the CMFPlone product.

More info:

* :doc:`How to override old style page templates </templates_css_and_javascripts/skin_layers>`

Creating and registering a view
===============================

This shows how to create and register view in a Zope 3 manner.

Creating a view using Grok
------------------------------

This is the simplest method and recommended for Plone 4.1+ onwards.

First, create your add-on product using :doc:`Dexterity project template </tutorials/paste>`.

Add the file ``yourcompany.app/yourcompany/app/browser/views.py``::

    """ Viewlets related to application logic.
    """

    # Zope imports
    from zope.interface import Interface
    from five import grok


    # Use templates directory to search for templates.
    grok.templatedir('templates')

    class MyView(grok.View):
        """ Render the title and description of item only (example)
        """

        # The view is available on every content item type
        grok.context(Interface)

The view in question is not registered against any :doc:`layer
</views/layers>`, so it is always available. The view becomes available upon
Zope start-up, and is available even if you don't run an add-on installer.
This is the suggested approach for logic views which are not theme related.

The ``grok.context(Interface)`` statement means that view is available for
every content item: You can use it in URLs like
``http://yoursite/news/newsitem/@@yourviewname`` or
``http://yoursite/news/@@yourviewname``. In the first case, the incoming
``self.context`` parameter received by the view would be the ``newsitem``
object, and in the second case, it would be the ``news`` container.

Alternatively, you could use the :doc:`content interface </content/types>`
docs to make the view available only for certain content types.

Then create ``yourcompany.app/yourcompany/app/browser/templates`` and add
the related template:

.. code-block:: xml

    <html xmlns="http://www.w3.org/1999/xhtml"
          xmlns:metal="http://xml.zope.org/namespaces/metal"
          xmlns:tal="http://xml.zope.org/namespaces/tal"
          xmlns:i18n="http://xml.zope.org/namespaces/i18n"
          i18n:domain="example.dexterityforms"
          metal:use-macro="context/main_template/macros/master">

        <metal:block fill-slot="main">

            <h1 class="documentFirstHeading" tal:content="context/Title | string:'No title'" />

            <p>This is an example view.</p>

            <div id="content-core">
                XXX - render content using content widgets
            </div>

        </metal:block>

    </html>

Another example (``empty.pt``), which renders only the title and description
fields in the Plone 3 way:

.. code-block:: xml

    <html xmlns="http://www.w3.org/1999/xhtml"
          xmlns:metal="http://xml.zope.org/namespaces/metal"
          xmlns:tal="http://xml.zope.org/namespaces/tal"
          xmlns:i18n="http://xml.zope.org/namespaces/i18n"
          i18n:domain="example.dexterityforms"
          metal:use-macro="context/main_template/macros/master">

        <metal:block fill-slot="main">

            <h1 class="documentFirstHeading" tal:content="context/pretty_title_or_id" />

            <p class="documentDescription" tal:content="context/Description|nothing" />

        </metal:block>

    </html>


Available :doc:`slot </templates_css_and_javascripts/template_basics>`
options you can use in the template:

* ``main`` - render edit border yourself
* ``content`` - render title your self
* ``content-core`` - title prerendered, Plone version > 4.x

Now you can access your view within the news folder::

    http://localhost:8080/Plone/news/myview

... or on a site root::

    http://localhost:8080/Plone/myview

... or on any other content item.

You can also use the ``@@`` notation at the front of the view name to make
sure that a view is being looked up. This is used to disambiguate between
view names and content item names, should these two be in conflict::

        http://localhost:8080/Plone/news/@@myview

More info

* http://plone.org/products/dexterity/documentation/manual/five.grok/browser-components/views

* http://plone.org/documentation/kb/how-to-write-templates-for-plone-4

Setting view permissions
^^^^^^^^^^^^^^^^^^^^^^^^^^

Use `grok.require <http://grok.zope.org/doc/current/reference/directives.html#grok-require>`_

Example::

	from five import grok

	class MyView(grok.View):

		# Require admin to access this view
		grok.require("cmf.ManagePortal")

Use :doc:`available permissions in Zope 3 style strings </security/permissions_lists>`.

More info:

* http://plone.org/products/dexterity/documentation/manual/five.grok/browser-components/views

Creating a view using ZCML
------------------------------

Example::

    # We must use BrowserView from view, not from zope.browser
    # Zope version does not
    from Products.Five.browser import BrowserView

    class MyView(BrowserView):

        def __init__(self, context, request):
            """
            This will initialize context and request object as they are given as view multiadaption parameters.

            Note that BrowserView constructor does this for you and this step here is just to show
            how view receives its context and request parameter. You do not need to write
            __init__() for your views.
            """
            self.context = context
            self.request = request

        # by default call will call self.index() method which is mapped
        # to ViewPageTemplateFile specified in ZCML
        #def __call__():
        #

.. warning::

        Do not attempt to run any code in the ``__init__()`` method of a
        view.  If this code fails and an exception is raised, the
        ``zope.component`` machinery remaps this to a "View not found"
        exception or traversing error.

        Instead, use a pattern where you have a ``setup()`` or similar
        method which ``__call__()`` or view users can explicitly call.

Registering a view
^^^^^^^^^^^^^^^^^^^^^

Zope 3 views are registered in :term:`ZCML`, an XML-based configuration
language.  Usually, the configuration file, where the registration done, is
called ``yourapp.package/yourapp/package/browser/configure.zcml``.

The following example registers a new view:

* ``for`` specifies which content types receive this view.  ``for="*"``
  means that this view can be used for any content type. This is the same as
  registering views to the ``zope.interface.Interface`` base class.

* ``name`` is the name by which the view is exposed to traversal and
  ``getMultiAdapter()`` look-ups. If your view's name is ``test``, then you
  can render it in the browser by calling http://yourhost/site/page/@@test

* ``permission`` is the permission needed to access the view.  When an HTTP
  request comes in, the currently logged in user's access rights in the
  current context are checked against this permission.  See :doc:`Security
  chapter </security/permission_lists.txt>` for Plone's out-of-the-box
  permissions. Usually you want have ``zope2.View``,
  ``cmf.ModifyPortalContent``, ``cmf.ManagePortal`` or ``zope2.Public``
  here.

* ``class`` is a Python dotted name for a class based on ``BrowserView``,
  which is responsible for managing the view. The Class's ``__call__()``
  method is the entrypoint for view processing and rendering.

* Note that you need to declare the ``browser`` namespace in your
  ``configure.zcml`` to use ``browser`` configuration directives:

.. code-block:: xml

    <configure
          xmlns="http://namespaces.zope.org/zope"
          xmlns:browser="http://namespaces.zope.org/browser"
          >

        <browser:page
              for="*"
              name="test"
              permission="zope2.Public"
              class=".views.MyView"
              />

    </configure>

Relationship between views and templates
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ZCML ``<browser:view template="">`` directive will set the ``index``
class attribute.

The default view's ``__call__()`` method will return the value
returned by a call to ``self.index()``.

Example: this ZCML configuration:

.. code-block:: xml

    <browser:page
        for="*"
        name="test"
        permission="zope2.Public"
        class=".views.MyView"
        />

and this Python code::

    from Products.Five.browser.pagetemplatefile import ViewPageTemplateFile

    class MyView(BrowserView):

        index = ViewPageTemplateFile("my-template.pt")

is equal to this ZCML configuration::

    <browser:page
        for="*"
        name="test"
        permission="zope2.Public"
        class=".views.MyView"
        template="my-template.pt"
        />

and this Python code::

    class MyView(BrowserView):
        pass

Rendering of the view is done by the following::

    from Products.Five.browser.pagetemplatefile import ViewPageTemplateFile

    class MyView(BrowserView):

        # This may be overridden in ZCML
        index = ViewPageTemplateFile("my-template.pt")

        def render(self):
            return self.index()

        def __call__(self):
            return self.render()

Overriding a view template in run-time
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Below is a sample code snippet which allows you to override an already
constructed ``ViewPageTemplateFile`` with a chosen file at run-time::

    import plone.z3cform
    from zope.app.pagetemplate import ViewPageTemplateFile as Zope3PageTemplateFile
    from zope.app.pagetemplate.viewpagetemplatefile import BoundPageTemplate
    # Construct template from a file which lies in a certain package
    template = Zope3PageTemplateFile('subform.pt', os.path.join(os.path.dirname(plone.z3cform.__file__), "templates"))
    # Bind template to context
    # This will make template callable with template() syntax and context
    form_instance.template = BoundPageTemplate(template, form_instance)

Several templates per view
^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can bind several templates to one view and render them in bits.
This is very useful for reusable templating, or when you subclass
your functional views.

Example using five.grok::

	class CourseTimetables(grok.View):

	    # For communicating state variables from Python code to Javascript
	    jsHeaderTemplate = grok.PageTemplateFile("templates/course-timetables-fees-js-snippet.pt")

	    def renderJavascript(self):
	        return self.jsHeaderTemplate.render(self)

And then call in the template:

.. code-block:: html

    <metal:javascriptslot fill-slot="javascript_head_slot">
        <script tal:replace="structure view/renderJavascript" />
    </metal:javascriptslot>

View ``__init__()`` method special cases
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

View ``__init__()``, Python constructor, method is special.  You should
never try to put your code there. Instead, use helper method or lazy
construction design pattern if you need to set-up view variables.

View ``__init__()`` might not have :doc:`acquisition chain
</serving/traversing>` available meaning that it does not the parent or
hierarchy where the view is. This information is set after the constructor
have been run.  All Plone code which relies on acquistion chain, which means
almost all Plone helper code, does not work in ``__init__()``.  Thus, the
called Plone API methods return ``None`` or tend to throw exceptions.

Layers
------

Views can be registered against a specific layer interface. This means that
views are only looked up if the specific layer is effective.  Since one Zope
application server can contain multiple Plone sites, layers are used to
determine which Python code is in effect for a given Plone site.

A layer can be be effective when:

* a certain theme is active, or
* if a specific add-on product is installed.

You should generally always register your views against a certain
layer in your own code.

For more information, see

* :doc:`browser layers </views/layers>`

Content type, mimetype and Template start tag
=============================================

If you need to produce other output than (X)HTML here are some resources

* http://plone.293351.n2.nabble.com/Setting-a-mime-type-on-a-Zope-3-browser-view-td4442770.html

Zope ViewPageTemplateFile vs. Five ViewPageTemplateFile
=======================================================

.. warning:: There are two ``ViewPageTemplateFile`` classes with the same
   name.

* Zope  `BrowserView source code <http://svn.zope.org/zope.publisher/trunk/src/zope/publisher/browser.py?rev=101538&view=auto>`_.

* `Five version  <http://svn.zope.org/Zope/trunk/src/Products/Five/browser/__init__.py?rev=96262&view=markup>`_. ``Products.Five`` is a way
  to access some of Zope 3 technologies from the Zope 2 codebase,
  which is used by Plone.

Difference in code::

    from Products.Five.browser.pagetemplatefile import ViewPageTemplateFile

vs.::

    from zope.app.pagetemplate import ViewPageTemplateFile


The difference is that the *Five* version supports:

* Acquisition
* provider: TAL expression
* Other Plone specific TAL expression functions like ``test()``
* Usually, Plone code needs the Five version of ``ViewPageTemplateFile``.
* Some subsystems, notably the ``z3c.form`` package, expect the Zope 3
  version of ``ViewPageTemplateFile`` instances.


Overriding a view class in a product
====================================

Most of the code in this section is copied from a `tutorial by Martin Aspeli
(on slideshare.net)
<http://www.slideshare.net/wooda/martin-aspeli-extending-and-customising-plone-3>`_.
The main change is that, at least for Plone 4, the interface should subclass
``plone.theme.interfaces.IDefaultPloneLayer`` instead of
``zope.interface.Interface``.

In this example we override the ``@@register`` form from the
``plone.app.users`` package, creating a custom form which subclasses the
original.

* Create an interface in ``interfaces.py``:

.. code-block:: python

    from plone.theme.interfaces import IDefaultPloneLayer

    class IExamplePolicy(IDefaultPloneLayer):
        """ A marker interface for the theme layer
        """

* Then create ``profiles/default/browserlayer.xml``:

.. code-block:: xml

    <layers>
      <layer
        name="example.policy.layer"
        interface="example.policy.interfaces.IExamplePolicy"
      />
    </layers>

* Create ``browser/configure.zcml``:

.. code-block:: xml

    <configure
        xmlns="http://namespaces.zope.org/zope"
        xmlns:browser="http://namespaces.zope.org/browser"
        i18n_domain="example.policy">
      <browser:page
          name="register"
          class=".customregistration.CustomRegistrationForm"
          permission="zope2.View"
          layer="..interfaces.IExamplePolicy"
          />
    </configure>

* Create ``browser/customregistration.py``:

.. code-block:: python

    from plone.app.users.browser.register import RegistrationForm

    class CustomRegistrationForm(RegistrationForm):
        """ Subclass the standard registration form
        """

Helper views
============

Not all views need to return HTML output, or output at all. Views can be
used as a helpers around in the code to provide APIs to objects. Since views
can be overridden using layers, a view is a natural plug-in point which an
add-on product can customize or override in a conflict-free manner.

View methods are exposed to page templates and such, so you can also call
view methods directly from a page template, besides Python code.

More information
----------------

* :doc:`Context helpers </misc/context>`

* :doc:`Expressions </functionality/expressions>`

Historical perspective
-----------------------

Often, the point of using helper views is that you can have reusable
functionality which can be plugged-in as one-line code around the system.
Helper views also get around the following limitations:

* TAL security

* Limiting Python expression to one line

* Not being able to import Python modules

.. Note::

        Using ``RestrictedPython`` scripts (creating Python through the Zope
        Management Interface) and Zope 2 Extension modules is discouraged.
        The same functionality can be achieved with helper views, with less
        potential pitfalls.

Reusing view template snippets or embedding another view
=============================================================

To use the same template code several times you can either

* Create a separate ``BrowserView`` for it and then call this view (see
  `Accessing a view instance in code`_ below)

* Share a ``ViewPageTemplate`` instance between views and using it several
  times

.. Note::

    The Plone 2.x way of doing this with TAL template language macros is
    discouraged to provide reusable functionality in your add-on product.
    This is because macros are hardwired to the TAL template language, and
    referring to them outside templates is difficult.

    Also, if you ever need to change the template language, or mix in other
    template languages, you can do it much more easily when templates are a
    feature of a pure Python based view, and not vice versa.

Here is an example of how to have a view snippet which can be used by
subclasses of a base view class. Subclasses can refer to this template
at any point of the view rendering, making it possible for subclasses
to have fine tuned control over how the template snippet is
represented.

Related Python code::

    from Products.Five import BrowserView
    from Products.Five.browser.pagetemplatefile import ViewPageTemplateFile

    class ProductCardView(BrowserView):
        """
        End user visible product card presentation.
        """
        implements(IProductCardView)

        # Nested template which renders address box + buy button
        summary_template = ViewPageTemplateFile("summarybox.pt")


        def renderSummary(self):
            """ Render summary box

            @return: Resulting HTML code as Python string
            """
            return self.summary_template()

Then you can render the summary template in the main template associated
with ProductCardView by calling the ``renderSummary()`` method and TAL
non-escaping HTML embedding.

.. code-block:: html

    <h1 tal:content="context/Title" />

    <div tal:replace="structure view/renderSummary" />

    <div class="description">
        <div tal:condition="python:context.Description().decode('utf-8') != u'None'" tal:replace="structure context/Description" />
    </div>

The ``summarybox.pt`` itself is just a piece of HTML code without the
Plone decoration frame (``main_template/master`` etc. macros).  Make sure
that you declare the ``i18n:domain`` again, or the strings in this
template will not be translated.

.. code-block:: html

    <div class="summary-box" i18n:domain="your.package">
        ...
    </div>

Accessing a view instance in code
===================================

You need to get access to the view in your code if you are:

* calling a view from inside another view, or
* calling a view from your unit test code.

Below are two different approaches for that.


By using ``getMultiAdapter()``
-------------------------------

This is the most efficient way in Python.

Example:

.. code-block:: python

    from Acquisition import aq_inner
    from zope.component import getMultiAdapter

    def getView(context, request, name):
        # Remove acquisition wrapper which may cause false context assumptions
        context = aq_inner(context)
        # Will raise ComponentLookUpError
        view = getMultiAdapter((context, request), name=name)
        # Put view to acquisition chain
        view = view.__of__(context)
        return view


By using traversal
-------------------

Traversal is slower than directly calling ``getMultiAdapter()``.  However,
traversal is readily available in templates and ``RestrictedPython``
modules.

Example:

.. code-block:: python

    def getView(context, name):
        """ Return a view which is associated with context object and current HTTP request.

        @param context: Any Plone content object
        @param name: Attribute name holding the view name
        """


        try:
            view = context.unrestrictedTraverse("@@" + name)
        except AttributeError:
            raise RuntimeError("Instance %s did not have view %s" % (str(context), name))

        view = view.__of__(context)

        return view

You can also do direct view look ups and method calls in your template
by using the @@ notation in traversing.

.. code-block:: html

    <div tal:attributes="lang context/@@plone_portal_state/current_language">
        We look up lang attribute by using BrowserView which name is "plone_portal_state"
    </div>


Use a skin-based template in a Five view
----------------------------------------

Use ``aq_acquire(object, template_name)``.

Example: Get an object by its path and render it using its default
template in the current context.

.. code-block:: python

    from Acquisition import aq_base, aq_acquire
    from Products.Five.browser import BrowserView

    class TelescopeView(BrowserView):
        """
        Renders an object in a different location of the site when passed the
        path to it in the querystring.
        """
        def __call__(self):
            path = self.request["path"]
            target_obj = self.context.restrictedTraverse(path)
            # Strip the target_obj of context with aq_base.
            # Put the target in the context of self.context.
            # getDefaultLayout returns the name of the default
            # view method from the factory type information
            return aq_acquire(aq_base(target_obj).__of__(self.context),
                              target_obj.getDefaultLayout())()

Listing available views
========================

This is useful for debugging purposes::

    from plone.app.customerize import registration
    from zope.publisher.interfaces.browser import IBrowserRequest

    # views is generator of zope.component.registry.AdapterRegistration objects
    views = registration.getViews(IBrowserRequest)

Listing all views of certain type
---------------------------------

How to filter out views which provide a certain interface::

    from plone.app.customerize import registration
    from zope.publisher.interfaces.browser import IBrowserRequest

    # views is generator of zope.component.registry.AdapterRegistration objects
    views = registration.getViews(IBrowserRequest)

    # Filter out all classes which do not filter a certain interface
    views = [ view.factory for view in views if IBlocksView.implementedBy(view.factory) ]


Default view of a content item
===============================

Objects have views for default, view, edit, and so on.

The distinction between the *default* and *view* views are that for files,
the default can be download.

The default view...

* This view is configured in :doc:`portal_types </content/types>`.

* This view is rendered when a content item is called - even though
  they are objects, they have the ``__call__()`` Python method
  defined.

If you need to get a content item's view for page
rendering explicitly, you can do it as follows::

    def viewURLFor(item):
        cstate = getMultiAdapter((item, item.REQUEST),
                                 name='plone_context_state')
        return cstate.view_url()

More info::

* :doc:`Context helpers and utilities </misc/context>`

* http://plone.293351.n2.nabble.com/URL-to-content-view-tp6028204p6028204.html

Views and magical acquisition
==================================

.. warning::

        This is really nasty stuff. If this were not be a public document
        I'd use more harsh words here.

In Plone 3, the following will lead to errors which are very hard to debug.

Views will automatically assign themselves as a parent for all member
variables.

E.g. you have a ``Basket`` content item with ``absolute_url()`` of::

        http://localhost:9666/isleofback/sisalto/matkasuunnitelmat/d59ca034c50995d6a77cacbe03e718de

Then if you use this object in a view code's member variable assignment::

        self.basket = my_basket

... this will mess up the Basket content item's acquisition chain::

    <Basket at /isleofback/sisalto/yritykset/katajamaan_taksi/d59ca034c50995d6a77cacbe03e718de>

One workaround to avoid this mess is to put a member variable inside a
Python array and create an accessor method to read it when needed::

    def initSomeVariables():

        basket = collector.get_collector(basket_folder, self.request, create)

        if basket is not None:
            # Work around acquisition wrapping thing
            # which forces the parent

            # Assign a variable inside an array which prevents automatic
            # acquisition wrapping for doing its broken magic or something
            # along the lines
            self.basket_holder = [ basket ]
        else:
            self.basket_holder = [ None ]

    def getCollector(self):
        """
        @return: User's collector object where pages are stored
        """
        return self.basket_holder[0]


