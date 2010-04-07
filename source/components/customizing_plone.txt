==================
Customizing Plone
==================

.. contents :: :local:

Introduction
------------

Plone can be customized in two different ways, depending on which kind of component you are trying to change

* Through-the-web

* By add-on products


You should never edit files directly in eggs folder. Instead you usually create a customized version of the
item you wish to modify and then configure Plone to use your customized version instead of stock one.

Through-the-web changes
-----------------------

Minor configuration changes can be done through the web. Through the web
changes are effective immediately and don't require you to write
any code or restart Zope application server. The downsite is that
since through-the-web changes don't have source code "recipe" how you did
the changes they are not repea    le. If you need to do the same changes
for another site again, or you need heavily modify your site, you
need go through manual steps to achieve the same customization.

Possible through-the-web changes are

* Site settings: E.g. adding/removing `content rules <http://plone.org/documentation/how-to/content-rules>`_

* Showing and hiding viewlets (parts of the page) using @@manage-viewlets

* Exporting and importing parts of the site configuration in portal_setup

* Customizing viewlet templates in portal_view_customization

* Customize portal_skins layer theme files in portal_skins

* Uploading Javascript files, CSS files and images through Zope management interface and registering using portal_css and portal_javascripts

Through the code changes
--------------------------

When you need to do expand Plone through Python the only way is to create your own add-on product for Plone.
Add-on products are distributed as packaged Python modules called eggs_.
The recommended way is to use paster_ command to generate add-on product skeleton which you can
use as a starting point for your development. Paster also contains useful subcommands, like addcontent,
which automatize various tasks of Plone add-on development.

* Another `paster tutorial <http://www.unc.edu/~jj/plone/>`_

.. _paster: http://plone.org/documentation/how-to/use-paster>

.. _eggs: http://plone.org/documentation/tutorial/buildout/packages-products-and-eggs
