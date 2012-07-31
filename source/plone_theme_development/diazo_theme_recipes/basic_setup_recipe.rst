===============================
Basic Setup Recipe
===============================

.. admonition:: Description

    Diazo is the system used to implement Plone themes.
    As of Plone 4.2, Plone ships with all the 'machinery'
    required to get started with Diazo based theme creation.
    In this tutorial we will create a very basic theme. In the 
    process you will gain experience with simple procedure for
    creating a Diazo theme.

.. contents:: :local:

Checklist
============

You will need to have the following:

* Your preferred text editor
* Access to working copy Plone 4.2 or Plone 4.1 with plone.app.theming 
* A Dropbox Account

Step 1 - Quick Test
==============================================================

Start by testing that everything is working.
In your Plone Site go to 'Site Setup' > 'Diazo theme'.

.. image:: ../images/sitesetup-cp.png

Then click on the 'Advanced Settings' tab.

.. image:: ../images/theming-cp-test.png

Enter the following values:

 **Rules file:** http://pigeonflight.github.com/diazodemo/rules.xml

 **Absolute path prefix:** http://pigeonflight.github.com/diazodemo/

 **Read network** should be checked, then click 'save'

 Visit your Plone site, the result will be a themed version of the plone site based on http://pigeonflight.github.com/diazodemo.

 It should look similar to this screenshot:

 .. image:: ../images/theming-test-screenshot.png
