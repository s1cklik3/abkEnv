#!/bin/bash 
# this script is collection of common function used in different scripts

declare -r TRUE=0
declare -r FALSE=1

# directories for bin and env files
BIN_DIR=$HOME/bin
ENV_DIR=$HOME/env

# GOCD installation settings
GOCD_INSTALLATION_DIR="$HOME/Library/Application Support/Go Agent"
GOCD_OVERRIDE_FILE="overrides.env"

# exit error codes
ERROR_CODE_SUCCESS=0
ERROR_CODE_GENERAL_ERROR=1
ERROR_CODE_IS_INSTALLED_BUT_NO_LINK=2
ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS=3
ERROR_CODE_NOT_BASH_SHELL=4
ERROR_CODE=$ERROR_CODE_SUCCESS

function GetAbsolutePath ()
{
    local DIR_NAME=$(dirname "$1")
    pushd "$DIR_NAME" > /dev/null
    local RESULT_PATH=$PWD
    popd > /dev/null
    echo $RESULT_PATH
}

function GetPathFromLink ()
{
    local RESULT_PATH=$(dirname $([ -L "$1" ] && readlink -n "$1"))
    echo $RESULT_PATH
}

function CreateLink ()
{
    if [ $# -ne 2 ]; then
        echo "ERROR: invalid number of parameters"
        false
    fi
    [ $TRACE != 0 ] && echo "creating link: $2 to target = $1"
    if [ -f "$1" ]; then
        [ -L "$2" ] && unlink "$2"
        ln -s "$1" "$2"
        LINK_RESULT=$([ $? == 0 ] && echo true || echo false )
        echo "[$LINK_RESULT]: $2 -> $1"
    else
        echo "target file $2 does not exist"
        LINK_RESULT=$( echo false )
    fi
    $LINK_RESULT
}

function DeleteLink ()
{
    if [ $# -ne 1 ]; then
        echo "ERROR: invalid number of parameters"
        echo "DeleteLink: requires only one parameter"
        false
    fi
    [ $TRACE != 0 ] && echo "\$1 = $1"
    #delete previous link association if needed
    [ -L "$1" ] && unlink "$1"
    LINK_RESULT=$([ $? == 0 ] && echo true || echo false )
    LINKED_TO="$(GetPathFromLink $1)/$(basename "$1")"
    echo "[$LINK_RESULT]: $1 -> $LINKED_TO"
    $LINK_RESULT
}