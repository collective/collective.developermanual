==============
Restyle A Form
==============

.. admonition :: Description

    How to inject CSS into a form page to turn a label green ... or pretty much anything else.

The general answer to "how do I restyle a form" questions is: use CSS.

The underlying Archetypes form generator surrounds every form element with a <div> with a distinct ID. For example, a sample form with a textarea contents field has the generated XHTML:

.. code-block:: xml

        <div class="field ArchetypesTextAreaWidget"
             id="archetypes-fieldname-comments">
          <span></span>
          <label for="comments">Comments</label>
          <span class="fieldRequired" title="Required">
            (Required)
          </span>
          <div class="formHelp" id="comments_help"></div>
          <textarea rows="5" name="comments" cols="40" id="comments"></textarea>
          <input type="hidden" name="comments_text_format" value="text/plain" />
        </div>

That's more than enough ID and Class selectors to do pretty much anything in the way of visual formatting.

So, how do we get the CSS into the form's page. You could add it to the site's css, but there's a much easier way. Using the ZMI, create an object of type File inside your form folder. Set its Content Type to "text/plain" and give it the ID "newstyle".

Let's turn the label for the comments field green. Just fill in the big text field on your file with:

.. code-block:: css

    <style>
    #archetypes-fieldname-comments label {
      color: green;
    }
    </style>

Now, just save it, return to the Plone UI and edit your form folder. Specify "here/newstyle" for the Header Injection field of the [overrides] pane. Now, enjoy your green label.

Need to do something more sophisticated? You can use a Python script to generate dynamic CSS or JavaScript. See Installing a JavaScript Event Handler in a Form for a how-to.