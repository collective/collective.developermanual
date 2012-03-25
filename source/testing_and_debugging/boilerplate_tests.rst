=================
Boilerplate tests
=================

These are test snippets useful for common use cases.


See
http://plone.org/documentation/manual/developer-manual/testing/writing-a-plonetestcase-unit-integration-test
to learn about PloneTestCase helper methods.

Test portal title::

    def test_portal_title(self):
        self.assertEquals("Plone site", self.portal.getProperty('title'))


Test if view is protected::

    def test_view_is_protected(self):
        from AccessControl import Unauthorized
        self.logout()
        self.assertRaises(
            Unauthorized,
            self.portal.restrictedTraverse,
            '@@view-name')


Test if object exists in folder::

    def test_object_in_folder(self):
        self.failIf('object_id' in self.portal.objectIds())


Javascript registered::

    def test_js_available(self):
        jsreg = getattr(self.portal, 'portal_javascripts')
        script_ids = jsreg.getResourceIds()
        self.failUnless('my-js-file.js' in script_ids)


CSS registered::

    def test_css_available(self):
        cssreg = getattr(self.portal, 'portal_css')
        stylesheets_ids = cssreg.getResourceIds()
        self.failUnless('MyCSS.css' in stylesheets_ids)


Test that a certain skin layer is present in portal_skins::

    def test_skin_layer_installed(self):
        self.failUnless('my-skin-layer' in self.skins.objectIds())
        self.failUnless('attachment_widgets' in self.skins.objectIds()) 

