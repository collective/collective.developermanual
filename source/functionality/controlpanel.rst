=============================
 Site setup and configuration
=============================

.. admonition:: Description

        How to create settings for your add-on product and how to programmatically
        add new Plone control panel entries.

.. contents :: :local:

Introduction
-------------

This documentation tells you how to create new "configlets" to 
Plone site setup control panel.

Configlets can be created 

* Using ``plone.app.registry`` configuration framework for Plone (recommended)

* Using any :doc:`view code </views/browserviews>`


plone.app.registry
-------------------

``plone.app.registry`` is the state of the art way to add settings for your Plone 4.x+ add-ons.

For tutorial and more information please see `PyPi page <http://pypi.python.org/pypi/plone.app.registry>`_.

Example products 

* http://pypi.python.org/pypi/collective.gtags

* http://plone.org/products/collective.habla

* http://pypi.python.org/pypi/collective.xdv

Minimal example using five.grok
===================================

Below is a minimal example for creating a configlet using

* `grok </components/grok>`

* ``plone.app.registry``

It is based on `youraddon template <https://github.com/miohtama/sane_plone_addon_template/tree/master>`_.
The add-on package in this case is called `silvuple <https://github.com/miohtama/silvuple>`_.

In buildout.cfg make sure you have `Dexterity extends line <http://plone.org/products/dexterity/documentation/how-to/install>´.

``setup.py``::

    install_requires = [..."plone.app.dexterity", "plone.app.registry"],

``settings.py``::

    """

        Define add-on settings.

    """

    from zope.interface import Interface
    from zope import schema
    from five import grok
    from Products.CMFCore.interfaces import ISiteRoot

    from plone.z3cform import layout
    from plone.directives import form
    from plone.app.registry.browser.controlpanel import RegistryEditForm
    from plone.app.registry.browser.controlpanel import ControlPanelFormWrapper

    class ISettings(form.Schema):
        """ Define settings data structure """
        
        adminLanguage = schema.TextLine(title=u"Admin language", description=u"Type two letter language code and admins always use this language")

    class SettingsEditForm(RegistryEditForm):
        """
        Define form logic
        """
        schema = ISettings
        label = u"Silvuple settings"

    class SettingsView(grok.CodeView):
        """
        View which wrap the settings form using ControlPanelFormWrapper to a HTML boilerplate frame.
        """
        grok.name("silvuple-settings")
        grok.context(ISiteRoot)
        def render(self):
            view_factor = layout.wrap_form(SettingsEditForm, ControlPanelFormWrapper)
            view = view_factor(self.context, self.request)
            return view()

``profiles/default/contropanel.xml``

.. code-block:: xml

    <?xml version="1.0"?>
    <object
        name="portal_controlpanel"
        xmlns:i18n="http://xml.zope.org/namespaces/i18n"
        i18n:domain="silvuple">

        <configlet
            title="Silvuple Settings"
            action_id="silvuple.settings"
            appId="silvuple"
            category="Products"
            condition_expr=""
            url_expr="string:${portal_url}/@@silvuple-settings"
            icon_expr=""
            visible="True"
            i18n:attributes="title">
                <permission>Manage portal</permission>
        </configlet>

    </object>

``profiles/default/registry.xml``

.. code-block:: xml

    <registry>
        <records interface="silvuple.settings.ISettings" prefix="silvuple">
            <!-- Set default values -->

            <!-- Leave to empty string -->
            <value key="adminLanguage"></value>
        </records>
    </registry>

Control panel widget settings
===================================

plone.app.registry provides `RegistryEditForm`
class which is a subclass of z3c.form.form.Form.

It has two phases to override which widgets
are going to be used for a which field.

* updateFields() may set widget factories i.e. widget type to be used

* updateWidgets() may play with widget properties and widget value
  shown to the user 
  
Example (*collective.gtags* project controlpanel.py)::
        
        class TagSettingsEditForm(controlpanel.RegistryEditForm):
            
            schema = ITagSettings
            label = _(u"Tagging settings") 
            description = _(u"Please enter details of available tags")
            
            def updateFields(self):
                super(TagSettingsEditForm, self).updateFields()
                self.fields['tags'].widgetFactory = TextLinesFieldWidget
                self.fields['unique_categories'].widgetFactory = TextLinesFieldWidget
                self.fields['required_categories'].widgetFactory = TextLinesFieldWidget
            
            def updateWidgets(self):
                super(TagSettingsEditForm, self).updateWidgets()
                self.widgets['tags'].rows = 8
                self.widgets['tags'].style = u'width: 30%;'

plone.app.registry imports - backwards compatibilty
===================================================

You need this if you have started using plone.app.registry before 2010-04.

There is a change considering the 1.0b1 codebase::

        
        try:
            # plone.app.registry 1.0b1
            from plone.app.registry.browser.form import RegistryEditForm
            from plone.app.registry.browser.form import ControlPanelFormWrapper
        except ImportError:
            # plone.app.registry 1.0b2+
            from plone.app.registry.browser.controlpanel import RegistryEditForm
            from plone.app.registry.browser.controlpanel import ControlPanelFormWrapper
            

Configlets without plone.registry
--------------------------------------------

Just add ``controlpanel.xml`` pointing to your custom form.


Content type choice setting
-------------------------------------

Often you need to have a setting whether a certain functionality is enabled on particular content types.

Here are the ingredients

* Custom schema defined interface for settings (registry.xml schemas don't support multiple choice widgets in plone.app.registry 1.0b2)

* :doc:`Vocabulary factory to pull type information out of portal_types </content/types>`

* Configlet

interfaces.py::

        from zope import schema
        
        from plone.directives import form
        from z3c.form.browser.checkbox import CheckBoxFieldWidget
        
        class ISettings(form.Schema):
            """ Define schema for settings of the add-on product """
        
        
            form.widget(enabled_overrides=CheckBoxFieldWidget)
            content_types = schema.List(title=u"Enabled content types",
                                       description=u"On which content types Facebook Like-button should appear",
                                       required=False, default=["Document"],
                                       value_type=schema.Choice(source="mfabrik.like.content_types"),
                                       )

configure.zcml

.. code-block:: xml

  <!-- make sure that plone.app.registry is loaded -->
  <includeDependencies package="." />

  <utility
      provides="zope.schema.interfaces.IVocabularyFactory"
      component=".vocabularies.content_types_vocabulary"
      name="mfabrik.like.content_types"
      />
      
  <browser:page
    name="like-controlpanel"
    for="Products.CMFPlone.interfaces.IPloneSiteRoot"
    permission="cmf.ManagePortal"
    class=".views.ControlPanelView"
    />
    
views.py::

        
        try:
            # plone.app.registry 1.0b1
            from plone.app.registry.browser.form import RegistryEditForm
            from plone.app.registry.browser.form import ControlPanelFormWrapper
        except ImportError:
            # plone.app.registry 1.0b2+
            from plone.app.registry.browser.controlpanel import RegistryEditForm
            from plone.app.registry.browser.controlpanel import ControlPanelFormWrapper
            
            
        from mfabrik.like.interfaces import ISettings
        from plone.z3cform import layout
        
        class ControlPanelForm(RegistryEditForm):
            schema = ISettings
        
        ControlPanelView = layout.wrap_form(ControlPanelForm, ControlPanelFormWrapper)

profiles/default/registry.xml::

        <registry>
        
            <records prefix="mfabrik.like" interface="mfabrik.like.interfaces.ISettings">
                
                <!-- Enable on normal pages by default --> 
                <value key="content_types" purge="false">
                       <element>Document</element>
                </value>
            </records>
        
        </registry>

profiles/default/controlpanel.xml::

        <?xml version="1.0"?>
        <object
            name="portal_controlpanel"
            xmlns:i18n="http://xml.zope.org/namespaces/i18n"
            i18n:domain="mfabrik.like">
        
            <configlet
                title="Facbook Like-button settings"
                action_id="mfbarik.like.settings"
                appId="mfabrik.like"
                category="Products"
                condition_expr=""
                url_expr="string:${portal_url}/@@like-controlpanel"
                icon_expr="string:"
                visible="True"
                i18n:attributes="title">
                    <permission>Manage portal</permission>
            </configlet>
        
        </object>

Then you can simply check whether a particular portal type is enabled
in your settings::

    
    from zope.component import getUtility
    from zope.component.interfaces import ComponentLookupError 
    
    from plone.registry.interfaces import IRegistry
    from mfabrik.like.interfaces import ISettings
    

    def isEnabledOnContent(self):
        """
        @return: True if the current content type supports Like-button
        """
    

    
        try:

            # Will raise an exception if plone.app.registry is not quick installed
            registry = getUtility(IRegistry)
            
            # Will raise exception if your product add-on installer has not been run
            settings = registry.forInterface(ISettings)
        except (KeyError, ComponentLookupError), e:
            # Registry schema and actual values do not match
            # Quick installer has not been run or need to rerun 
            # to update registry.xml values to database
            # http://svn.plone.org/svn/plone/plone.registry/trunk/plone/registry/registry.py
            return False
        
        content_types = settings.content_types
            
        # Don't assume that all content items would have portal_type attribute
        # available (might be changed in the future / very specialized content)
        current_content_type =  portal_type = getattr(Acquisition.aq_base(self.context), 'portal_type', None)
        
        return current_content_type in content_types


Configuring plone products from buildout
----------------------------------------

See a section in the :ref:`Buildout chapter <configuring-products-from-buildout>`


Configuration using environment variables
-----------------------------------------

If your add-on requires "setting file" 
for few simple settings you can change for each
buildout you can use operating system environment variables.

For example, see

* http://pypi.python.org/pypi/Products.LongRequestLogger
