==========================
Creating a Multi-Page Form
==========================

.. admonition :: Description

    You can create a multi-page form as a chain of form folders.

Creating a multi-page form is probably much simpler than you might suppose. You may do it by just creating a sequence of form folders that each link to the next.
The basic procedure is:

* Create your sequence of form folders, typically all in the same normal Plone folder;
* On all but the last form folder, turn off all action adapters and set the Custom Success Action override to "traverse_to:string:id-of-next-form-folder";
* On all but the last form folder, set the Submit Button Label to something like "Next" and turn off the cancel button.
* On all but the first form folder, set the Exclude From Navigation flag in the properties tab;
* In each form folder, create a set of hidden form fields matching all the fields in all the previous forms;
* In the last form, turn on your real action adapter(s).

As your user moves from form page to page, input will be automatically saved in the hidden fields of subsequent pages.

.. note::

    A Note on Hidden Fields: The hidden flag is not available for all form field types, but you don't need it. String, Text and Lines fields are adequate to carry all the basic data. Use a hidden Lines field to hold multiple selection field input, string or text for the rest.