#!/bin/bash
TEST_FLAG=1

LICN_FILE=$1
GOLDILOCKS_LICENSE=$GOLDILOCKS_HOME/license/license

echo "+----------------------------------+"
echo "¦ Goldilocks license installation. ¦"
echo "+----------------------------------+"
echo ""

failExit() {
    echo "+----------------------------------------+"
    echo "¦ !!!! license installation failed. !!!! ¦"
    echo "+----------------------------------------+"
    echo ""
    exit
}

envCheck(){
    if [ -z "$GOLDILOCKS_HOME" ]; then
        echo "Error: $GOLDILOCKS_HOME env is not set." >&2
        echo "Did you Install Goldilocks package?"
        echo ""
        failExit
    fi
}

addProperty() {
    echo "License File : $LICN_FILE"
    ## if LICN_FILE don't exist
    if [ ! -f "$LICN_FILE" ]; then
        echo "License file does not exist."
        echo "Check the file and try again."
        echo "How to use : $(basename $0) license" >&2
        failExit
    else
        echo LICN_FILE >$GOLDILOCKS_LICENSE
        echo "- License added succesfully."
        echo ""
        sleep 2
    fi
}
### CHECK ENV
envCheck


### ADD LICENSE
if [ $TEST_FLAG -eq 1 ]; then
    addLicense
fi

echo "+--------------------------------------------+"
echo "¦ Goldilocks license installation finished.  ¦"
echo "+--------------------------------------------+"
echo ""
