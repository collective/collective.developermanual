=========================
From Zope to the Browser 
=========================

.. admonition:: Description

		How do content types get "published" (in the Zope sense, not
		the workflow sense) to the web browser? 

There is a fairly complex mechanism that determines how a content object
ends up being displayed in the browser. The following is an adaptation
of an email to the plone-devel list which aims to untangle this
complexity. It pertains to Plone 2.1 only.
Assumptions:
 o You want the ‘view’ action to be the same as what happens when you go
to the object directly for most content types…
o …but for some types, like File and Image, you want the “view” action
to display a template, whereas if you go straight to the object, you get
the file’s contents
o You want to be able to redefine the ‘view’ action in your custom
content types or TTW in portal\_types explicitly. This will essentially
override the current layout template selection. Probably this won’t be
done very often for things deriving from ATContentTypes, since here you
can register new templates with the FTI and have those be used (via the
“display” menu) in a more flexible (e.g. per-instance, user-selectable)
way, but you still want the “view” action to give the same power to
change the default view of an object as it always has.
o When you use the “display” menu (implemented with IBrowserDefault) to
set a default page in a folderish container, you want it to display that
item always, unless there is an index\_html - index\_html always wins
(note - the “display” menu is disabled when there is an index\_html in
the folder, precisely because it will have no effect)
o When you use the “display” menu to set a layout template for an object
(folderish or not), you want that to be displayed on the “view” tab
(action), as well as by default when the object is traversed to without
a template/action specified…
o …except for ATFile and ATImage, which use a method index\_html() to
cut in when you don’t explicitly specify an item. However, these types
will \*still\* want their “view” action to show the selected layout, but
will want a no-template invocation to result in the file content
Some implementation detail notes:
 There are two distinct cases:
CASE I: “New-style” content types using the paradigms of ATContentTypes
– These implement ISelectableBrowserDefault, now found in the generic
CMFDynamicViewFTI product. They support the “display” menu with
per-instance selectable views, including the ability to select a
default-page for folders via the GUI. These use CMF 1.5 features
explicitly.
CASE II: “Old-style” content types, including CMF types and old AT types
– These do not implement this interface. The “display” menu is not used.
The previous behaviour of Plone still holds.
The “old-style” behaviour is implemented using the Zope hook
\_\_browser\_default\_\_(), which exists to define what happens when you
traverse to an object without an explicit page template or method. This
is used to look up the default-page (e.g. index\_html) or discover what
page template to render. In Plone, \_\_browser\_default\_\_() calls
PloneTool.browserDefault() to give us a single place to keep track of
this logic. The rules are (slightly simplified):
1. A method, attribute or contained object ‘index\_html’ will always
win. Files and Images use this to dump content (via a method
index\_html()); creating a content object index\_html in a folder as a
defualt page is the now-less-encouraged way, but should still be the
method that trumps all others.
2. A propery ‘default\_page’ set on a folderish object giving the id of
a contained object to be the default-page is checked next.
3. A property ‘default\_page’ in ‘site\_properties’ gives us a list of
ids to check and treat similarly to index\_html. If a folder contains
items with any of these magic ids, the first one found will be used as a
default-page.
4. If the object has a ‘folderlisting’ action, use this. This is a funny
fallback which is necessary for old-style folders to work (see below).
5. Look up the object’s ‘view’ action and use this if none of the above
hold true.
In addition, we test for ITranslatable to allow the correct translation
of returned pages to be selected (LinguaPlone), and have some WebDAV
overrides.
Lastly, it has always been possible to put “/view” at the end of a URL
and get the view of the object, regardless of any index\_html() method.
This means that you can go to /path/to/file/view and get the view of the
file, even if /path/to/file would dump the content (since it has an
index\_html() method that does that).
This mechanism uses the method view(), defined in PortalContent in CMF
(and also in BaseFolder in Archetypes). view() returns ‘self()’, which
results in a call to \_\_call\_\_(). In CMF 1.4, this would look up the
‘view’ action and resolve this. Note that for \*folders\* in Plone 2.0,
the ‘view’ action is just ‘string:${object\_url}/’, which in turn
results in \_\_browser\_default\_\_() and the above rules. This means
that /path/to/folder/view will rend TRUNCATED! Please download pandoc if
you want to convert large files.