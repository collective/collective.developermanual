======
Tricks
======

.. admonition:: Description

.. contents :: :local:


Specify files and code from another package
===========================================

If you ever find yourself needing to use a template
from another package, you can do so with using the
configure tag which will then run the block of zcml
in the context of that package.

Here is an example of defining portlet manager to be
defined in another manager::

    <configure
        xmlns="http://namespaces.zope.org/zope"
        xmlns:browser="http://namespaces.zope.org/browser"
        i18n_domain="my.package">

        <!-- Moved viewlet registration -->
        <configure package="Products.ContentWellPortlets">
            <browser:viewlet
                name="contentwellportlets.portletsabovecontent"
                class="Products.ContentWellPortlets.browser.viewlets.PortletsAboveViewlet"
                manager="plone.app.layout.viewlets.interfaces.IBelowContentTitle"
                layer="Products.ContentWellPortlets.browser.interfaces.IContentWellPortlets"
                permission="zope2.View"
                template="browser/templates/portletsabovecontent.pt"
            /> 
        </configure>
     
    </configure>


Conditionally run zcml
======================

You can conditionally run zcml if a certain package or feature is installed.

First, include the namespace at the top of the zcml file::

    <configure
        xmlns="http://namespaces.zope.org/zope"
        xmlns:zcml="http://namespaces.zope.org/zcml"
        i18n_domain="my.package">
    ....

Examples
--------

conditionally run for package::

    <include zcml:condition="installed some.package" package=".package" />
    <include zcml:condition="not-installed some.package" package=".otherpackage" />

conditionally run for feature::

    <include zcml:condition="have plone-4" package=".package" />
    <include zcml:condition="not-have plone-4" package=".otherpackage" />
