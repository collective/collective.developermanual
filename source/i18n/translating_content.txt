====================
Translated content
====================

.. contents :: :local:

.. admonition:: Description

        Translating content items in Plone, creating translations
        programmatically and working with translators.

Introduction
=============

Content translations usually are handled by the well-established
`LinguaPlone add-on product <http://plone.org/products/linguaplone>`_.

For an example of a content type using LinguaPlone, see the `LinguaItem example type <http://svn.plone.org/svn/plone/LinguaPlone/tags/2.1.1/Products/LinguaPlone/examples/LinguaItem.py>`_.

We also present ``raptus.multilanguageplone`` as an alternative approach.

Translation-aware content types (Archetypes)
=============================================

LinguaPlone makes it possible to mark fields *language independent* or
*language dependent*.

.. note ::

    To have language-aware behavior, you need to use the
    ``Products.LinguaPlone.public.*`` API, instead of
    ``Products.Archetypes.atapi.*``.

Example::

    try:
        from Products.LinguaPlone import public as atapi
    except ImportError:
        # No multilingual support
        from Products.Archetypes import atapi

    class MyContent(atapi.ATContent):
        pass

    atapi.registerType(MyContent, ...)


For more information, see:

* http://pypi.python.org/pypi/Products.LinguaPlone/3.1a2#language-independent-fields

* http://n2.nabble.com/languageIndependent-fields-not-updated-td2430489.html

Getting content items in another language
=========================================

Possible use cases:

- Getting translated content items by known path. E.g. you could have a
  content item called ``portal/footer``, which dynamically shows translated
  text for different languages.

- Displaying content in many languages simultaneously.

To show some content translated into the chosen language of the current
user, you can use ``ITranslatable.getTranslation()``::

    def getTranslation(language='language'):
        """
        Return the object corresponding to a translated version or None.
        If called without arguments it returns the translation in the currently
        selected language, or self.
        """

Example::

    class Footer(BaseViewlet):
        """ A footer viewlet which will gather editable and translated footer text.

        The localized text is available as an Archetypes Page object
        with the id "footer-text" in the site root. LinguaPlone
        translation look-up is performed.

        1. Create the footer in the main language of your site as a
           hidden Page, with the id "footer-text".

        2. Use the "Translate to..." action to create localized versions
           of this footer.

        3. Leave the footer in the *private* workflow state, so that it
           does not appear in the search results, etc.

        Note that the workflow state of the footer content is not
        considered.

        Note that the id "footer" is reserved in Plone, thus we use
        "footer-text".
        """

        grok.name("plone.footer")
        grok.viewletmanager(IPortalFooter)

        def getFooterText(self):
            """ Call this from your viewlet template.

            Example::

                <div id="portal-footer">
                  <div tal:replace="structure viewlet/getFooterText" />
                </div>
            """

            from Products.LinguaPlone.interfaces import ITranslatable

            portal = self.portal_state().portal()

            if "footer-text" in portal.objectIds(): # Note that you can use has_key() for BTree based folders
                footer = portal["footer-text"]
                if ITranslatable.providedBy(footer):
                    translated = footer.getTranslation()
                    if translated:
                        return translated.getText()

                return footer.getText()

            return ""

Translating content
===================

LinguaPlone contains some unit test code which shows how to create
translations.  You can use the ``context.addTranslation(language_code)`` and
``context.getTranslation(language_code)`` methods.

Example::

    from Products.LinguaPlone.I18NBaseObject import AlreadyTranslated

    try:
        object.addTranslation(lang)
    except AlreadyTranslated:
        # Note: AlreadyTranslated is always raised if Products.Linguaplone is not installed
        pass

    translated = object.getTranslation(lang)


See http://svn.plone.org/svn/plone/LinguaPlone/tags/2.1.1/Products/LinguaPlone/tests/translate_edit.txt

.. XXX: Why link to a particular (ancient) tag?

Serving translated content from a correct domain name
=======================================================

The following applies if:

* You use one Plone instance to host a site translated into several
  languages;
* the Plone instance is mapped to different domain names;
* the language is resolved based on the top-level domain name or the
  subdomain.

For SEO and usability reasons, you might want to force certain content to
show up at a certain domain.  Plone does not prevent you from accessing a
path such as ``/news`` on the Finnish domain, or ``/uutiset`` on English
domain.  If these URLs leak to search engines, they cause confusion.

Below is a complex post-publication hook which redirects users to the
proper domain for the language being served::

    """ Domain-aware language redirects.

        Redirect the user to the domain where the language should be
        served from, if they have been mixing and matching different domain
        names and language versions.

        http://mfabrik.com
    """

    import urlparse

    from zope.interface import Interface
    from zope.component import adapter, getUtility, getMultiAdapter
    from plone.postpublicationhook.interfaces import IAfterPublicationEvent

    from gomobile.mobile.utilities import get_host_domain_name
    from gomobile.mobile.interfaces import IMobileRequestDiscriminator, MobileRequestType

    from Products.CMFCore.interfaces import IContentish

    def get_contentish(object):
        """ Traverse acquisition upwards until we get a contentish object used for the HTTP response.
        """

        contentish = object

        while not IContentish.providedBy(contentish):
            if not hasattr(contentish, "aq_parent"):
                break
            contentish = contentish.aq_parent

        return contentish


    def redirect_domain(request, response, new_domain):
        """ Redirect user to a new domain, with the URI intact.

        It also keeps the port.

        @param new_domain: New domain name to redirect, without port.
        """

        url = request["ACTUAL_URL"]
        parts = urlparse.urlparse(url)

        # Replace domain name
        parts = list(parts)
        netloc = parts[1]

        # TODO: Handle @ and HTTP Basic auth here
        if ":" in netloc:
            domain, port = netloc.split(":")
            netloc = new_domain + ":" + port
        else:
            netloc = new_domain

        parts[1] = netloc
        new_url = urlparse.urlunparse(parts)

        # Make 301 Permanent Redirect response
        response.redirect(new_url, status=301)
        response.body = ""
        response.setHeader("Content-length", 0)


    def ensure_in_domain(request, response, language_now, wanted_language, wanted_domain):
        """ Make sure that a certain language gets served from the correct domain.

        If the user tries to access URI of page, and the page language
        does not match the domain we expect, redirect the user to the
        correct domain.
        """

        domain_now = get_host_domain_name(request)

        if language_now == wanted_language:
            if domain_now != wanted_domain:
                # print "Fixing language " + language_now + " to go to " + wanted_domain + " from " + domain_now
                redirect_domain(request, response, wanted_domain)


    @adapter(Interface, IAfterPublicationEvent)
    def language_fixer(object, event):
        """ Redirect mobile users to mobile site using gomobile.mobile.interfaces.IRedirector.

        Note: Plone does not provide a good hook for doing this before
        traversing, so we must do it in post-publication. This adds extra
        latency, but is doable.
        """

        # print "language_fixer"

        request = event.request
        response = request.response
        context = get_contentish(object)

        if hasattr(context, "Language"):
            # Check whether the context has a Language() accessor, to get
            # the original language:
            language_now = context.Language()

            #print "Resolving mobility"
            discriminator = getUtility(IMobileRequestDiscriminator)
            flags = discriminator.discriminate(context, request)

            if MobileRequestType.MOBILE in flags:
                # Do mobile
                ensure_in_domain(request, response, language_now, "fi", "m.mfabrik.fi")
                ensure_in_domain(request, response, language_now, "en", "mfabrik.mobi")
            else:
                # Do web
                ensure_in_domain(request, response, language_now, "fi", "mfabrik.fi")
                ensure_in_domain(request, response, language_now, "en", "mfabrik.com")

        # print "Done"

Another approach (`raptus.multilanguageplone`)
==============================================

Another extension for multilingual content in Plone is
``raptus.multilanguageplone``.  This is not meant to be a fully-fledged tool
for content translaton, unlike LinguaPlone. Translation is done directly in
the edit view of a content type, and provides a widget to use google's
translation API to translate the different fields.

Unlike LinguaPlone, ``raptus.multilanguageplone`` doesn't create an object
for each translation. Instead, it stores the translation on the object
itself and therefor doesn't support translation workflows and language-aware
object paths.

If you have non-default content types, you have to provide your own
``multilanguagefields`` adapter.

See https://svn.plone.org/svn/collective/raptus.multilanguagefields/trunk/raptus/multilanguagefields/samples/

Installation
============

Installation of ``raptus.multilanguageplone`` is straight-forward with
buildout. If the site already contains articles then you have to migrate
them.

See http://pypi.python.org/pypi/raptus.multilanguagefields

Switching from Linguaplone
==========================

If you want to switch from Linguaplone to ``raptus.multilanguageplone`` be
aware that you will lose already translated content.

1. Uninstall ``Products.Linguaplone``.
2. Unfortunately Linguaplone does not uninstall cleanly. Two utilities
   remain in your database. You can remove them in an interactive session
   from your site (in this example, the site has the id 'plone')::

       (Pdb) site = plone.getSiteManager()
       (Pdb) from plone.i18n.locales.interfaces import IContentLanguageAvailability
       (Pdb) utils = site.getAllUtilitiesRegisteredFor(IContentLanguageAvailability)
       (Pdb) utils
       [<plone.i18n.locales.languages.ContentLanguageAvailability object at 0xb63c4cc>,
       <ContentLanguages at /plone/plone_app_content_languages>,
       <Products.LinguaPlone.vocabulary.SyncedLanguages object at 0xfa32e8c>,
       <Products.LinguaPlone.vocabulary.SyncedLanguages object at 0xfa32eac>]
       (Pdb) utils = utils[:-2]
       (Pdb) del site.utilities._subscribers[0][IContentLanguageAvailability]

   Repeat the procedure for ``IMetadataLanguageAvailability`` and commit the
   transaction::

       (Pdb) import transaction
       (Pdb) site._p_changed = True
       (Pdb) site.utilities._p_changed = True
       (Pdb) transaction.commit()
       (Pdb) app._p_jar.sync()   # if zeo setup

3. Run buildout without Linguaplone and restart.
4. Run the *import* step of the Plone Language Tool. Otherwise language
   switching will not work.
5. Install ``raptus.multilanguageplone`` using buildout and
   ``portal_quickinstaller``.
6. Migrate the content.

