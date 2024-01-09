#!/bin/bash
TEST_FLAG=1

CONF_FILE=$1
GOLDILOCKS_PROPERTY=$GOLDILOCKS_DATA/conf/goldilocks.property.conf

echo "+----------------------------------+"
echo "¦ Goldilocks config installation.  ¦"
echo "+----------------------------------+"
echo ""

failExit() {
    echo "+---------------------------------------+"
    echo "¦ !!!! Config installation failed. !!!! ¦"
    echo "+---------------------------------------+"
    echo ""
    exit
}

envCheck(){
    if [ -z "$GOLDILOCKS_DATA" ]; then
        echo "Error: $GOLDILOCKS_DATA env is not set." >&2
        failExit
    fi
}

addProperty() {
    ## if CONF_FILE don't exist
    if [ ! -f "$CONF_FILE" ]; then
        echo "Config file does not exist."
        echo "Check the file and try again."
        echo "How to use : $(basename $0) package_name.tar.gz goldilocks.conf license" >&2
        failExit
    else
        echo "- Copy Config File."
        cp $GOLDILOCKS_DATA/conf/goldilocks.properties.conf $GOLDILOCKS_DATA/conf/goldilocks.properties.conf.bak_$(date +%Y%m%d%H%M%S)
        yes | cp -rf $CONF_FILE $GOLDILOCKS_DATA/conf/goldilocks.properties.conf
        if [ $? -eq 0 ]; then
            echo "    property imported succesfully."
            echo ""
        else
            failExit
        fi
    fi
}

### ADD PROPERTY
if [ $TEST_FLAG -eq 1 ]; then
    addProperty
fi

echo "+--------------------------------------------+"
echo "¦ Goldilocks license installation finished.  ¦"
echo "+--------------------------------------------+"
echo ""
