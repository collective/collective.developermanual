===============================
Quick Test Recipe
===============================

.. admonition:: Description

    Diazo is the system used to implement Plone themes.
    As of Plone 4.2, Plone ships with all the 'machinery'
    required to get started with Diazo based theme creation.
    This recipe is designed to get you started quickly. 

.. contents:: :local:

Ingredients
============

You will need to have the following:

* Access to working copy Plone 4.2 or Plone 4.1 with plone.app.theming 

Procedure
==================================

Start by testing that everything is working. For this test our theme resources are hosted on a github page (http://pigeonflight.github.com).

In your Plone Site go to 'Site Setup' > 'Diazo theme'.

.. image:: ../images/sitesetup-cp.png

.. note:: If you don't see the 'Diazo theme' option, go to 'Site Setup' > 'Add-ons', select 'Diazo theme support' and click 'Activate'.

In the Diazo theming control panel click on the 'Advanced Settings' tab.

.. image:: ../images/theming-cp-test.png

Enter the following values:

 **Rules file:** http://pigeonflight.github.com/diazodemo/rules.xml

 **Absolute path prefix:** http://pigeonflight.github.com/diazodemo/

 **Read network** should be checked, then click 'save'

.. note:: The rule file and resources in this example are hosted online, we assume this may be a problem if your Plone site is behind a firewall or otherwise not connected to the internet.

Visit your Plone site, the result will be a themed version of the plone site based on http://pigeonflight.github.com/diazodemo.

It should look similar to this screenshot:

 .. image:: ../images/plone_theme_dev_theming-test-screenshot.png
