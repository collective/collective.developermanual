# Makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = bin/sphinx-build
SPHINXINTLBUILD   = bin/sphinx-intl
TX            = bin/tx
PAPER         =

# Internal variables.
PAPEROPT_a4     = -D latex_paper_size=a4
PAPEROPT_letter = -D latex_paper_size=letter
ALLSPHINXOPTS   = -d build/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) source
I18NOPTS        = -p locale/pot -c source/conf.py -l fr -l it -l de
LANGS           = en it

.PHONY: help clean html dirhtml pickle json htmlhelp qthelp latex changes linkcheck doctest

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  html      to make standalone HTML files"
	@echo "  dirhtml   to make HTML files named index.html in directories"
	@echo "  pickle    to make pickle files"
	@echo "  gettext   to make i18n messages files"
	@echo "  transifex-init to register new resources in transifex"
	@echo "  transifex-pull to pull resources from Transifex"
	@echo "  json      to make JSON files"
	@echo "  htmlhelp  to make HTML files and a HTML help project"
	@echo "  qthelp    to make HTML files and a qthelp project"
	@echo "  latex     to make LaTeX files, you can set PAPER=a4 or PAPER=letter"
	@echo "  changes   to make an overview of all changed/added/deprecated items"
	@echo "  linkcheck to check all external links for integrity"
	@echo "  doctest   to run all doctests embedded in the documentation (if enabled)"

clean:
	-rm -rf build/*

#html:
#	$(SPHINXBUILD) -b html $(ALLSPHINXOPTS) build/html
#	@echo
#	@echo "Build finished. The HTML pages are in build/html."



html: $(foreach lang,$(LANGS),html-$(lang))

html-%: $(SPHINX_DEPENDENCIES)
	$(SPHINXBUILD) -b html -D language=$* $(ALLSPHINXOPTS) build/html/$*
	@echo
	@echo "Build finished. The HTML pages are in build/html."

#html-it:
#	$(SPHINXBUILD) -b html -D language=it $(ALLSPHINXOPTS) build/html-it
#	@echo
#	@echo "Build finished. The HTML pages are in build/html."

gettext:
	$(SPHINXBUILD) -b gettext source locale
	@echo
	@echo "Build finished. The HTML pages are in build/gettext."

transifex-init:
	$(SPHINXINTLBUILD) update-txconfig-resources $(I18NOPTS) --transifex-project-name plone-doc

transifex-pull:
	$(SPHINXBUILD) -b gettext source locale/pot
	$(TX) pull $(I18NOPTS)
	$(SPHINXINTLBUILD) $(I18NOPTS) build
	@echo
	@echo "Build finished. The HTML pages are in build/html."

dirhtml:
	$(SPHINXBUILD) -b dirhtml $(ALLSPHINXOPTS) build/dirhtml
	@echo
	@echo "Build finished. The HTML pages are in build/dirhtml."

pickle:
	$(SPHINXBUILD) -b pickle $(ALLSPHINXOPTS) build/pickle
	@echo
	@echo "Build finished; now you can process the pickle files."

json:
	$(SPHINXBUILD) -b json $(ALLSPHINXOPTS) build/json
	@echo
	@echo "Build finished; now you can process the JSON files."

htmlhelp:
	$(SPHINXBUILD) -b htmlhelp $(ALLSPHINXOPTS) build/htmlhelp
	@echo
	@echo "Build finished; now you can run HTML Help Workshop with the" \
	      ".hhp project file in build/htmlhelp."

qthelp:
	$(SPHINXBUILD) -b qthelp $(ALLSPHINXOPTS) build/qthelp
	@echo
	@echo "Build finished; now you can run "qcollectiongenerator" with the" \
	      ".qhcp project file in build/qthelp, like this:"
	@echo "# qcollectiongenerator build/qthelp/PloneDeveloperManual.qhcp"
	@echo "To view the help file:"
	@echo "# assistant -collectionFile build/qthelp/PloneDeveloperManual.qhc"

latex:
	$(SPHINXBUILD) -b latex $(ALLSPHINXOPTS) build/latex
	@echo
	@echo "Build finished; the LaTeX files are in build/latex."
	@echo "Run \`make all-pdf' or \`make all-ps' in that directory to" \
	      "run these through (pdf)latex."

changes:
	$(SPHINXBUILD) -b changes $(ALLSPHINXOPTS) build/changes
	@echo
	@echo "The overview file is in build/changes."

linkcheck:
	$(SPHINXBUILD) -b linkcheck $(ALLSPHINXOPTS) build/linkcheck
	@echo
	@echo "Link check complete; look for any errors in the above output " \
	      "or in build/linkcheck/output.txt."

doctest:
	$(SPHINXBUILD) -b doctest $(ALLSPHINXOPTS) build/doctest
	@echo "Testing of doctests in the sources finished, look at the " \
	      "results in build/doctest/output.txt."

epub:
	$(SPHINXBUILD) -b epub $(ALLSPHINXOPTS) build/epub
	@echo
	@echo "Build finished. The e-Pub pages are in build/epub."
