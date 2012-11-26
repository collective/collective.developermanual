#!/bin/sh
#
# Do a git pull on the docs, see if anything has changed.
# If so rebuild the docs (clean rebuild) and sync to the target.
# Must be run within the buildout directory.
#
#


deploy_target=/var/www/developer.plone.org/var/public_html

# http://stackoverflow.com/questions/3258243/git-check-if-pull-needed
git pull | grep -q -v 'Already up-to-date.' && changed=1

if [[ ! -z "$changed" ]] ; then
    # Rebuild the docs from the scratch
    bin/buildout
    make clean html

    # Copy docs to the target in-place, so even if someone is reading
    # the site there is no service interrupts
    install -d $deploy_target
    rsync -a --inplace build/html/* $deploy_target
    echo "Copied docs to $deploy_target"
else
    echo "Git was up to date - no docs built"
fi