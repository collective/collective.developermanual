==============
Restyle a form
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

Now, just save it, return to the Plone UI and edit your form folder. Specify "here/newstyle" for the Header Injection field of the ``overrides`` pane. Now, enjoy your green label.

Putting checkboxes in a row
===========================

Now, for a more useful example. It's a common requirement to want to put a set of checkbox fields on a single line.

The easiest way to set this up is to create the list of checkboxes as a multi-selection field with "checkboxes" designated for display. That's going to generate markup that will look something like this:

.. code-block:: xml

  <div id="my-questions">
    <div class="formQuestion label">
        My Questions
        <span id="my-questions_help" class="formHelp"></span>
    </div>
    <div id="archetypes-value-my-questions_1" class="ArchetypesMultiSelectionValue">
      <input type="checkbox" name="my-questions:list" value="a" id="my-questions_1" class="blurrable">
      <label for="my-questions_1">Choice A</label>
    </div>
    <div id="archetypes-value-my-questions_2" class="ArchetypesMultiSelectionValue">
      <input type="checkbox" name="my-questions:list" value="b" id="my-questions_2" class="blurrable">
      <label for="my-questions_2">Choice B</label>
    </div>
    <div id="archetypes-value-my-questions_3" class="ArchetypesMultiSelectionValue">
      <input type="checkbox" name="my-questions:list" value="c" id="my-questions_3" class="blurrable">
      <label for="my-questions_3">Choice C</label>
    </div>
  </div>

Note that each checkbox/label pair is in a ``DIV`` with the class "ArchetypesMultiSelectionValue". The basic CSS couldn't be simpler:


.. code-block:: css

    <style>
    #my-questions div.ArchetypesMultiSelectionValue {
        float: left;
    }
    </style>

Of course, you'll need to do some more styling. First of all, you'll need to set a ``clear: left`` on the following control. And, you'll need to do some padding.

An alternative way to inject CSS
================================

Let's say you've got a lot of CSS. You may want to use an external style sheet file rather than inject the whole bundle into the header with every form display.

Let's say the CSS resource is named ``form_styles.css``. Then, just put the following in your overrides / header injection field::

    string:<style>@import url(form_styles.css)</style>


We can get a little fancier to generate absolute URLs for the style file::

    string:<style>@import url(${here/form_styles.css/absolute_url})</style>


using the string interpolation feature of TALES.


.. note::

    Need to do something more sophisticated? You can use a Python script to generate dynamic CSS or JavaScript.
