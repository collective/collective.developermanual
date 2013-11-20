#!/bin/bash
#

rm source/_static/contributors.js 2>&1 > /dev/null
rm source/_templates/contributors.html 2>&1 > /dev/null
rm source/_static/transparency.min.js 2>&1 > /dev/null
ln -s `pwd`/src/sphinxcontrib.contributors/src/sphinxcontrib/contributors/contributors.js source/_static/ 2>&1 > /dev/null
ln -s `pwd`/src/sphinxcontrib.contributors/src/sphinxcontrib/contributors/transparency.min.js source/_static/ 2>&1 > /dev/null
ln -s `pwd`/src/sphinxcontrib.contributors/src/sphinxcontrib/contributors/contributors.html source/_templates/  2>&1 > /dev/null

rm build/html/_static/contributors.css 2>&1 > /dev/null
rm build/html/_static/contributors.js 2>&1 > /dev/null
ln -s `pwd`/src/sphinxcontrib.contributors/src/sphinxcontrib/contributors/contributors.css build/html/_static/ 2>&1 > /dev/null
ln -s `pwd`/src/sphinxcontrib.contributors/src/sphinxcontrib/contributors/contributors.js build/html/_static/ 2>&1 > /dev/null
