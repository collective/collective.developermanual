#!/bin/bash
#
# Capture plone.app.widgets widgets demo page
#

URL="http://localhost:9090/Plone/@@widgets-demo"

TARGET_FILE=widgets.html

TARGET=source/_generated/widgets/

CWD=`pwd`

# Start site temporary
bin/instance-widget-capture start
sleep 3

TDIR=`mktemp -d`
echo "Capturing page $URL to $TDIR"

trap "cd $CWD" SIGINT
cd $TDIR ; wget --no-directories --level=1 --recursive --convert-links "$URL"
GET_STATUS=$?
cd $CWD

# Stop site
bin/instance-widget-capture stop

# man pages don't tell about wget exit codes
if [[ $GET_STATUS != 8 ]] ; then
    echo "Could not succesfully read $URL, wget exit status $GET_STATUS"
    exit 1
fi

cp -r $TDIR/* $TARGET

rm -rf $TDIR



