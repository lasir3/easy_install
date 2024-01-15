#!/bin/bash

TEST_FLAG=1

CHECK_SHELL=$(echo $SHELL | awk -F'/' '{print $NF}')
SYSTEM=$(uname)

DBUSER=$(whoami)

## need to be changed to read function
SYMLNK_PATH=$HOME

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
    FILE_NAME=$(echo "$PACKAGE_NAME" | awk -F/ '{if (NF>1) {print $NF} else {print $0}}' | sed -e 's/.tar.gz$//')
    EXTENSION=$(echo "$PACKAGE_NAME" | awk -F. '{if (NF>1) {print $(NF-1)"."$NF}}')
    PAK_VER_NAME=$(echo "$PACKAGE_NAME" | awk -F. '{if (NF>1) {print $1" "$4"Tag"}}')

    # echo "    File Name : $FILE_NAME"
    # echo "    Extension : $EXTENSION"
    if [ ! -f "${PACKAGE_NAME}" ]; then
        echo "Package file does not exist."
        echo "Check the file and try again."
        echo ""
        # echo "How to use : $(basename $0) package_name.tar.gz" >&2
        exit 2
    elif [ "$EXTENSION" != "tar.gz" -o -z "$EXTENSION" ]; then
        echo "Invalid package file. Check the package file again."
        # echo "How to use : $(basename $0) package_name.tar.gz" >&2
        exit 2
    else
        echo "###########################"
        echo "## Start Installation... ##"
        echo "###########################"
        echo ""
        # echo "Package File : $PACKAGE_NAME"
        ver_Prefix=$(echo $PACKAGE_NAME | grep -oP 'server-\K[^.]*')
        ver_Suffix=$(echo $PACKAGE_NAME | grep -oP '\.\K\d+(?=-)')

        ver_Result="Goldilocks ${ver_Prefix} ${ver_Suffix}Tag"
        echo "Package Version : $ver_Result"
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
        echo "    Invalid package file. Check the package file again." >&2
        failExit
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
    ### zsh
    zsh)
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
    if [ ! -d "${INSTALL_DIR}" ]; then
        mkdir $INSTALL_DIR
    fi
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
        echo "    ERROR : '${INSTALL_DIR}${FILE_NAME}' Package already exists."
        echo ""
        failExit
    fi
}

exportEnvVariable_Linux() {
    if [ $PATCH_FLAG = 0 ]; then
        ## CHECK EXSITING ENV
        echo "- Checking Goldilocks Env..."
        if [ ! -z "$GOLDILOCKS_HOME" -o ! -z "$GOLDILOCKS_DATA" ]; then
            echo "    Error: Goldilocks Env already exist." >&2
            echo "    Did you Install Goldilocks package before?"
            echo ""
            failExit
        else
            echo "   Goldilocks Env is Empty."
            echo ""
            echo "- Import enviromnet to PROFILE."
            echo "

###### GOLDILCOKS ENV START ######

export GOLDILOCKS_HOME=\$HOME/goldilocks_home
export GOLDILOCKS_DATA=\$HOME/goldilocks_data
export PATH=\$GOLDILOCKS_HOME/bin:\$PATH
export LD_LIBRARY_PATH=\$GOLDILOCKS_HOME/lib:\$LD_LIBRARY_PATH

###### GOLDILCOKS ENV END ######

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
        fi
    fi

}

makeSymlnk() {
    echo "- Creating Symbolic Link"
    sleep 2
    #### goldilocks_home
    ## Patch flag ON
    if [ $PATCH_FLAG -eq 0 ]; then
        ## goldilocks_home sim.link not exist && goldilocks_home dir exist
        if [ ! -d ${SYMLNK_PATH}/goldilocks_home -a -d ${INSTALL_DIR}${FILE_NAME}/goldilocks_home ]; then
            ln -s ${INSTALL_DIR}${FILE_NAME}/goldilocks_home ${SYMLNK_PATH}/goldilocks_home
            if [ $? -eq 0 ]; then
                echo "        'goldilocks_home' Symbolic Link Created."
                echo "            Symbolic Link Directory : $SYMLNK_PATH/goldilocks_home"
                echo "            Link Directory : ${INSTALL_DIR}${FILE_NAME}/goldilocks_home"
                echo ""
                sleep 2
            else
                echo "        Simbolic Link creation failed"
                failExit
            fi
        else
            echo "        error : 'goldilocks_home' Sysmbolic Link already exsist."
            echo "        DB Patch Disabled."
            echo ""
            failExit
        fi

    ## PATCH FLAG 1
    else
        ## goldilocks_home sim.link not exist && goldilocks_home dir exist
        if [ ! -d ${SYMLNK_PATH}/goldilocks_home -a -d ${INSTALL_DIR}${FILE_NAME}/goldilocks_home ]; then
            echo "        error : 'goldilocks_home' Symbolic Link dose not exist."
            echo "        Goldilocks package should already exist for the patch."
            echo "        Goldilocks Patch Failed."
            echo ""
            failExit
        else
            ln -Tfs ${INSTALL_DIR}${FILE_NAME}/goldilocks_home ${SYMLNK_PATH}/goldilocks_home
            if [ $? -eq 0 ]; then
                echo "        'goldilocks_home' Patch Done."
                echo "            Symbolic Link Directory : $SYMLNK_PATH/goldilocks_home"
                echo "            Link Directory : ${INSTALL_DIR}${FILE_NAME}/goldilocks_home"
                echo ""
                sleep 2
            else
                echo "        DB Patch Failed."
                failExit
            fi
        fi
    fi

    #### goldilocks_data
    if [ $PATCH_FLAG -eq 0 ]; then
        ## goldilocks_data sim.link not exist && goldilocks_data dir exist
        if [ ! -d ${SYMLNK_PATH}/goldilocks_data -a -d ${INSTALL_DIR}${FILE_NAME}/goldilocks_data ]; then
            ln -s ${INSTALL_DIR}${FILE_NAME}/goldilocks_data ${SYMLNK_PATH}/goldilocks_data
            if [ $? -eq 0 ]; then
                echo "        'goldilocks_data' Symbolic Link Created."
                echo "            Symbolic Link Directory : $SYMLNK_PATH/goldilocks_data"
                echo "            Link Directory : ${INSTALL_DIR}${FILE_NAME}/goldilocks_data"
                echo ""
                sleep 2
            else
                echo "        Symbolic Link creation failed"
                failExit
            fi
        else
            echo "        error : 'goldilocks_data' Symbolic Link already exsist."
            echo "        DB Patch Disabled."
            echo ""
            failExit
        fi
    else
        echo "        'goldilocks_data' does not need patch. Skipping process."
        # current_Prefix=$(echo $(readlink -f $GOLDILOCKS_DATA) | grep -oP 'server-\K[^.]*')
        # current_Suffix=$(echo $(readlink -f $GOLDILOCKS_DATA) | grep -oP '\.\K\d+(?=-)')

        # current_Result="Goldilocks ${current_Prefix} ${current_Suffix}Tag"
        # echo "            Package Version : $current_Result"
        # echo ""
        echo "            Symbolic Link Directory : $SYMLNK_PATH/goldilocks_data"
        echo "            current Link Directory : $(readlink -f $GOLDILOCKS_DATA)"
        echo ""
    fi
}

#################################
######### FUNCTION END ##########
#################################




################################
######### SHELL START ##########
################################
echo "+-----------------------------------+"
echo "¦ Goldilocks Package Install Shell. ¦"
echo "+-----------------------------------+"
echo ""

while true; do
    echo "1. Install New Package"
    echo "2. Patch Database"
    read -p "Choose the number (1-2): " choice

    case $choice in
    1)
        echo "- Selected Install New Package."
        echo ""
        read -p "Where is Package File Directory? : " PACKAGE_NAME
        read -p "Where do you want to Install? : " INSTALL_DIR
        echo ""
        echo "Package File Directory : $PACKAGE_NAME"
        echo "Install Directory : $INSTALL_DIR"
        echo ""
        read -p "Are you sure? (y/n) : " answer
        echo ""
        if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
            PATCH_FLAG=0
            break
        elif [ "$answer" == "N" ] || [ "$answer" == "n" ]; then
            echo "Installation Canceled."
            echo ""
            exit
        else
            echo "Please choose 'y' or 'n'."
            echo "" 
        fi
        ;;
    2)
        echo "- Selected Patch Database."
        echo ""
        read -p "Where is Package File Directory? : " PACKAGE_NAME
        read -p "Where do you want to Install? : " INSTALL_DIR
        echo ""
        echo "Package File Directory : $PACKAGE_NAME"
        echo "Install Directory : $INSTALL_DIR"
        echo ""
        read -p "Are you sure? (y/n) : " answer
        echo ""
        if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
            PATCH_FLAG=1
            break
        elif [ "$answer" == "N" ] || [ "$answer" == "n" ]; then
            echo "Installation Canceled."
            echo ""
            exit
        else
            echo "Please choose 'y' or 'n'."
            echo "" 
        fi
        ;;
    *)
        echo "- Wrong number. Choose the correct number again."
        echo ""
        ;;
    esac
done


################################
### FAIL TEST
################################
if [ $TEST_FLAG -eq 0 ]; then
    failExit
fi
################################
################################


### PACKAGE FILE VERIFICATION
if [ $TEST_FLAG -eq 1 ]; then
    packageVerf
fi

### SPECIFY PROFILE LOCATION
if [ $TEST_FLAG -eq 1 ]; then
    checkProfile
fi

### IMPORT ENVEROMENT
if [ $TEST_FLAG -eq 1 ]; then
    exportEnvVariable_Linux
fi

### CREATE PACKAGE DIRECTORY
if [ $TEST_FLAG -eq 1 ]; then
    installPackage
fi

### CREATE SYMBOLIC LINK
if [ $TEST_FLAG -eq 1 ]; then
    makeSymlnk
fi

### PROCESS DONE
if [ $PATCH_FLAG = 1 ]; then
    echo "+--------------------------------------------------------+"
    echo "¦ Goldilocks package patch finished.                     ¦"
    echo "+--------------------------------------------------------+"
    echo ""
else
    echo "+---------------------------------------------------------------+"
    echo "¦ Goldilocks package installation finished.                     ¦"
    echo "¦                                                               ¦"
    echo "¦ !!!!!!! Attention !!!!!!!!                                    ¦"
    echo "¦  You are now required to either re-login to your session      ¦"
    echo "¦    or export the environment from the profile.                ¦"
    echo "¦ - Example) source ~/.bash_profile                             ¦"
    echo "+---------------------------------------------------------------+"
    echo ""
fi
##############################
######### SHELL END ##########
##############################