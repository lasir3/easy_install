#!/bin/bash
TEST_FLAG=1

CHECK_SHELL=$(echo $SHELL | awk -F'/' '{print $NF}')
SYSTEM=$(uname)

DBUSER=$(whoami)

PACKAGE_NAME=$1
CONF_FILE=$2
LICN_FILE=$3

## need to be changed to read function
SYMLNK_PATH=$HOME

FILE_NAME=$(echo "$PACKAGE_NAME" | awk -F/ '{if (NF>1) {print $NF} else {print $0}}' | sed -e 's/.tar.gz$//')
EXTENSION=$(echo "$PACKAGE_NAME" | awk -F. '{if (NF>1) {print $(NF-1)"."$NF}}')

## need to be changed to read function
INSTALL_DIR=/home/$DBUSER/product/

PATCH_FLAG=0

# DBCREATE_FLAG=1

# GOLDILOCKS_USER_ENV=${INSTALL_DIR}/goldilocks_data/conf/.goldilocks.user.env
GOLDILOCKS_PROPERTY=${INSTALL_DIR}${FILE_NAME}/goldilocks_data/conf/goldilocks.property.conf
GOLDILOCKS_LICENSE=${INSTALL_DIR}${FILE_NAME}/goldilocks_home/license/license

###########################
######## Functions ########
###########################

failExit() {
    echo "+----------------------------------------+"
    echo "¦ !!!! Package installation failed. !!!! ¦"
    echo "+----------------------------------------+"
    echo ""
    exit
}

packageVerf() {
    echo "Package File : $(basename $FILE_NAME)"
    echo "Config File : $(basename $CONF_FILE)"
    echo "License File : $(basename $LICN_FILE)"
    echo ""
    # echo "    File Name : $FILE_NAME"
    # echo "    Extension : $EXTENSION"
    if [ ! -f "$PACKAGE_NAME" ]; then
        echo "Package file does not exist."
        echo "Check the file and try again."
        echo "How to use : $(basename $0) package_name.tar.gz goldilocks.conf license" >&2
        exit 2
    elif [ "$EXTENSION" != "tar.gz" -o -z "$EXTENSION" ]; then
        echo "Invalid package file. Check the package file again."
        echo "How to use : $(basename $0) package_name.tar.gz goldilocks.conf license" >&2
        exit 2
    elif [ ! -f "$CONF_FILE" ]; then
        echo "Config file does not exist."
        echo "Check the file and try again."
        echo "How to use : $(basename $0) package_name.tar.gz goldilocks.conf license" >&2
        exit 2
    elif [ ! -f "$LICN_FILE" ]; then
        echo "License file does not exist."
        echo "Check the file and try again."
        echo "How to use : $(basename $0) package_name.tar.gz goldilocks.conf license" >&2
        exit 2
    else
        echo "Start Installation...."
        echo ""
    fi
    ## If package name is correct....
    ## Verify Package with directory name
    echo "- Verifying Package...."
    tar -tzf $PACKAGE_NAME | grep -E 'goldilocks_data' >/dev/null
    if [ $? -eq 0 ]; then
        echo "    The package file is correct."
        sleep 2
        echo ""
    else
        echo "    Invalid package file. Check the package file again."
        exit 2
    fi
}

checkProfile() {
    echo "- Check profile location."
    case $CHECK_SHELL in
    ### bash
    bash)
        if [ -f "${HOME}/.bash_profile" ]; then
            PROFILE_PATH="${HOME}/.bash_profile"
        elif [ -f "${HOME}/.bash_login" ]; then
            PROFILE_PATH="${HOME}/.bash_login"
        elif [ -f "${HOME}/.profile" ]; then
            PROFILE_PATH="${HOME}/.profile"
        else
            PROFILE_PATH="${HOME}/.bash_profile"
        fi
        ;;
    ### sh
    sh)
        PROFILE_PATH="${HOME}/.profile"
        ;;
    ### else
    *)
        echo "    Set enveroment variables in your shell yourself."
        return
        ;;
    esac
    echo "    Profile path : $PROFILE_PATH"
    echo ""
    sleep 2
}

installPackage() {
    echo "- Starting package installation..."
    # echo "    Package File : $FILE_NAME"
    if [ ! -d "${INSTALL_DIR}${FILE_NAME}" ]; then
        tar -zxf $PACKAGE_NAME -C $INSTALL_DIR
        if [ $? -eq 0 ]; then
            echo "    Package installation complete."
            echo "    Directory path : $INSTALL_DIR$FILE_NAME"
            echo ""
            sleep 2
        else
            echo "Package installation failed."
            echo ""
            failExit
        fi
    else
        echo "    ERROR : '${INSTALL_DIR}${FILE_NAME}' Directory already exists."
        failExit
    fi
}

exportEnvVariable_Linux() {
    # ### CREATE ENV FILE
    # if [ ! -f "$GOLDILOCKS_USER_ENV" ]; then
    #     touch $GOLDILOCKS_USER_ENV 2>&1
    #     if [ $? -eq 0 ]; then
    #         echo "Created ENV file."
    #         echo ""
    #     else
    #         echo "EVN file create failed."
    #         echo ""
    #         failExit
    #     fi
    # fi

    ### IMPORT ENV VARIABLES
    ############################################################
    # set Linux Env into ${INSTALL_DIR}/conf/.goldilocks.user.env
    ############################################################

    echo "- Import enviromnet to PROFILE."
    echo "

###### GOLDILCOKS ENV ######

export GOLDILOCKS_HOME=\$HOME/goldilocks_home
export GOLDILOCKS_DATA=\$HOME/goldilocks_data
export PATH=\$GOLDILOCKS_HOME/bin:\$PATH
export LD_LIBRARY_PATH=\$GOLDILOCKS_HOME/lib:\$LD_LIBRARY_PATH
        " >>$PROFILE_PATH
    if [ $? -eq 0 ]; then
        echo "    Import environment to PROFILE_PATH successfully."
        echo ""
        sleep 2
    else
        echo "    Import environment Failed."
        echo ""
        failExit
    fi
    echo "- Applying evnromnet file."
    source $PROFILE_PATH

    # echo $GOLDILOCKS_DATA
    # echo $GOLDILOCKS_HOME
    if [ $? -eq 0 ]; then
        echo "    Apply success."
        echo ""
        sleep 2
    else
        echo "    Apply fail."
        echo ""
        failExit
    fi

    echo "    [ Linux Env. ]
 	Target : $PROFILE_PATH

 	    GOLDILOCKS_HOME : $GOLDILOCKS_HOME
 	    GOLDILOCKS_DATA : $GOLDILOCKS_DATA
 	    PATH            : $PATH
 	    LD_LIBRARY_PATH : $LD_LIBRARY_PATH
    "
    sleep 2
}

makeSymlnk() {
    echo "- Creating Symbolic Link"
    echo ""
    echo "    [ Creating goldilocks_home Symbolic Link.... ]"
    #### goldilocks_home
    ## Patch flag ON
    if [ $PATCH_FLAG -eq 0 ]; then
        ## goldilocks_home sim.link not exist && goldilocks_home dir exist
        if [ ! -d ${SYMLNK_PATH}/goldilocks_home -a -d ${INSTALL_DIR}${FILE_NAME}/goldilocks_home ]; then
            ln -s ${INSTALL_DIR}${FILE_NAME}/goldilocks_home ${SYMLNK_PATH}/goldilocks_home
            if [ $? -eq 0 ]; then
                echo "        goldilocks_home Symbolic Link Created."
                echo "            Link Directory : ${INSTALL_DIR}${FILE_NAME}/goldilocks_home"
                echo ""
                sleep 2
            else
                echo "        Simbolic Link creation failed"
                failExit
            fi
        else
            echo "        error : goldilocks_home Sysmbolic Link already exsist."
            echo "        DB Patch Disabled."
            echo ""
            failExit
        fi

    ## PATCH FLAG 1
    else
        ## goldilocks_home sim.link not exist && goldilocks_home dir exist
        if [ ! -d ${SYMLNK_PATH}/goldilocks_home -a -d ${INSTALL_DIR}${FILE_NAME}/goldilocks_home ]; then
            echo "        error : goldilocks_home Symbolic Link dose not exist."
            echo "        DB Patch Disabled."
            echo ""
            failExit
        else
            ln -Tfs ${INSTALL_DIR}${FILE_NAME}/goldilocks_home ${SYMLNK_PATH}/goldilocks_home
            if [ $? -eq 0 ]; then
                echo "        goldilocks_home Patch Done."
                echo "            Link Directory : ${INSTALL_DIR}${FILE_NAME}/goldilocks_home"
                echo ""
                sleep 2
            else
                echo "        DB Patch Failed."
                failExit
            fi
        fi
    fi

    echo "    [ Creating goldilocks_data Simbolic Link.... ]"
    #### goldilocks_data
    if [ $PATCH_FLAG -eq 0 ]; then
        ## goldilocks_data sim.link not exist && goldilocks_data dir exist
        if [ ! -d ${SYMLNK_PATH}/goldilocks_data -a -d ${INSTALL_DIR}${FILE_NAME}/goldilocks_data ]; then
            ln -s ${INSTALL_DIR}${FILE_NAME}/goldilocks_data ${SYMLNK_PATH}/goldilocks_data
            if [ $? -eq 0 ]; then
                echo "        goldilocks_data Symbolic Link Created."
                echo "            Link Directory : ${INSTALL_DIR}${FILE_NAME}/goldilocks_data"
                echo ""
                sleep 2
            else
                echo "        Symbolic Link creation failed"
                failExit
            fi
        else
            echo "        error : goldilocks_data Symbolic Link already exsist."
            echo "        DB Patch Disabled."
            echo ""
            failExit
        fi
    else
        echo "        goldilocks_data does not need patch. Skipping process."
    fi
}

addProperty() {
    echo "- Copy Config File."
    cp $GOLDILOCKS_DATA/conf/goldilocks.properties.conf $GOLDILOCKS_DATA/conf/goldilocks.properties.conf.bak_$(date +%Y%m%d%H%M%S)
    yes | cp -rf $CONF_FILE $GOLDILOCKS_DATA/conf/goldilocks.properties.conf
    if [ $? -eq 0 ]; then
        echo "    property imported succesfully."
        echo ""
    fi
}

addLicense() {
    if [ -f "$LICN_FILE" ]; then
        echo license >$GOLDILOCKS_LICENSE
        echo "- License added succesfully."
        echo ""
        sleep 2
    else
        echo "- License add failed."
        echo ""
        failExit
    fi
}

#################################
######### FUNCTION END ##########
#################################

################################
######### SHELL START ##########
################################
echo "+----------------------------------+"
echo "¦ Goldilocks package installation. ¦"
echo "+----------------------------------+"
echo ""

################################
### FAIL TEST
################################
if [ $TEST_FLAG -eq 0 ]; then
    failExit
fi
################################

### PACKAGE FILE VERIFICATION
if [ $TEST_FLAG -eq 1 ]; then
    packageVerf
fi

### CREATE PACKAGE DIRECTORY
if [ $TEST_FLAG -eq 1 ]; then
    installPackage
fi

### SPECIFY PROFILE LOCATION
if [ $TEST_FLAG -eq 1 ]; then
    checkProfile
fi

### IMPORT ENVEROMENT
if [ $TEST_FLAG -eq 1 ]; then
    exportEnvVariable_Linux
fi

### CREATE SYMBOLIC LINK
if [ $TEST_FLAG -eq 1 ]; then
    makeSymlnk
fi

### ADD PROPERTY
if [ $TEST_FLAG -eq 1 ]; then
    addProperty
fi

### ADD LICENSE
if [ $TEST_FLAG -eq 1 ]; then
    addLicense
fi

echo "+---------------------------------------------------------------+"
echo "¦ Goldilocks package installation finished.                     ¦"
echo "¦                                                               ¦"
echo "¦ !!!!!!! Attention !!!!!!!!                                    ¦"
echo "¦  You are now required to either re-login to your session      ¦"
echo "¦    or export the environment from the profile.                ¦"
echo "¦ - Example) source ~/.bash_profile                             ¦"
echo "+---------------------------------------------------------------+"
echo ""
