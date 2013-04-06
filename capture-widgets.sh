#!/bin/bash
#
# Capture plone.app.widgets widgets demo page
#

URL="http://localhost:8080/Plone/@@widgets-demo"

TARGET_FILE=widgets.html

TARGET=source/_generated/widgets/

CWD=`pwd`

# Start site temporary
bin/instance-widget-capture start
sleep 3

TDIR=`mktemp -d`
echo "Capturing page $URL to $TDIR"

trap control_c "cd $CWD"
cd $TDIR ; wget --quiet --no-directories --level=1 --recursive --convert-links "$URL"
GET_STATUS=$?
cd $CWD

# Stop site
bin/instance-widget-capture stop

# man pages don't tell about wget exit codes
if [[ $GET_STATUS != 0 ]] ; then
    echo "Could not succesfully read $URL"
    exit 1
fi

cp -r $TDIR $TARGET

rm $TDIR



