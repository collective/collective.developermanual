==========================
Theming guide for Plone 3
==========================

Preface
-------------

This is a theming guide for Plone 3. The technologies here work
directly on Zope Page Templates (TAL) and viewlets.
On Plone 4.2+ versions of Plone the suggested approach for theming your site
is `plone.app.theming <http://pypi.python.org/pypi/plone.app.theming>`_
where you can create your theme through-the-web and with less
needed low level programming information.

Even if not recommended the techniques described are
still useful and might be needed with new versions of Plone.
Please consult
`stackoverflow.com (plone tag) <http://stackoverflow.com/questions/tagged/plone>`_ or
`plone-users mailing list <http://plone.org/support/forums/general>`_
when in confusion.

Introduction
-------------

.. toctree::
    :maxdepth: 1

    intro/intro
    intro/what
    intro/overview

Quick start
-------------

.. toctree::
    :maxdepth: 1

    quick-start/overview
    quick-start/change-the-logo
    quick-start/change-the-font-colours
    quick-start/firefox-mozilla-ui-development-tools

Approaches
------------

.. toctree::
    :maxdepth: 1

    approaches/plonedefault
    approaches/filesystem
    approaches/directions

Tools
---------

.. toctree::
    :maxdepth: 1

    tools/authoring
    tools/debug
    tools/egg1/overview

Building blocks
-------------------

**Overview**

.. toctree::
    :maxdepth: 1

    buildingblocks/overview

**Templates**

.. toctree::
    :maxdepth: 1


    buildingblocks/skin/templates/overview

**Componentws**

.. toctree::
    :maxdepth: 1

    buildingblocks/components/wiring
    buildingblocks/components/viewletsandportlets
    buildingblocks/components/customizing
    buildingblocks/components/componentparts/interfaces
    buildingblocks/components/componentparts/pythonclasses
    buildingblocks/components/componentparts/permissions
    buildingblocks/components/themespecific
    buildingblocks/components/skinorcomponents
    buildingblocks/components/locations

**Skin layers**

.. toctree::
    :maxdepth: 1

    buildingblocks/skin/layers/overview
    buildingblocks/skin/layers/precedence
    buildingblocks/skin/layers/making

**Skin templates**

.. toctree::
    :maxdepth: 1

    buildingblocks/skin/templates/overview
    buildingblocks/skin/templates/getting-started
    buildingblocks/skin/templates/macros-and-slots
    buildingblocks/skin/templates/advanced-usage
    buildingblocks/skin/templates/global-template-variables
    buildingblocks/skin/templates/how-to-customise-view-or-edit-on-archetypes-content-items
    buildingblocks/skin/templates/create-an-alternative-edit-template

**Customizing Archetypes templates**

.. toctree::
    :maxdepth: 1

    buildingblocks/skin/templates/customizing-at-templates/introduction
    buildingblocks/skin/templates/customizing-at-templates/what-makes-it-tick
    buildingblocks/skin/templates/customizing-at-templates/customizing-widgets
    buildingblocks/skin/templates/customizing-at-templates/customizing-at-templates
    buildingblocks/skin/templates/customizing-at-templates/conclusion
    buildingblocks/skin/templates/customizing-at-templates/reference




Content to be migrated
---------------------------

    tools/index
    buildingblocks/index
    page/index
    elements/index
    whereiswhat/index
    illustrations/index
    rule-based-theming/index