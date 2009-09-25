#!/bin/sh
#
# Fix Eclipse default setting tab = 4 four spaces, indent = tab in all files
#
#
# Mikko Ohtamaa <mikko.ohtamaa (At) twinapex.com> http://www.twinapex.com
#
#

#!/bin/ksh

files=`find . -iname "*.txt"`

for iter in $files
do
	echo $iter
    sed 's/tab/    /g' "${iter}" > filename.notabs && mv filename.notabs "${iter}"
done