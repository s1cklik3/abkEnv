#!/bin/bash 
# this script is collection of common function used in different scripts

#---------------------------
# variables definitions
#---------------------------
declare -r TRUE=0
declare -r FALSE=1

# directories for bin and env files
BIN_DIR=$HOME/bin
ENV_DIR=$HOME/env
SH_BIN_DIR="macBin"
SH_ENV_DIR="macEnv"
SH_PACKAGES_DIR="macPackages"
SH_DIR=""

# abkEnv bash profile file names
NEW_BASH_PROFILE="bash_profile.env"
ORG_BASH_PROFILE=".bash_profile"
ABK_BASH_PROFILE="bash_abk.env"

# GOCD installation settings
GOCD_INSTALLATION_DIR="$HOME/Library/Application Support/Go Agent"
GOCD_OVERRIDE_FILE="overrides.env"

# exit error codes
ERROR_CODE_SUCCESS=0
ERROR_CODE_GENERAL_ERROR=1
ERROR_CODE_NOT_BASH_SHELL=2
ERROR_CODE_IS_INSTALLED_BUT_NO_LINK=3
ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS=4
ERROR_CODE_NOT_VALID_PARAMETER=5
ERROR_CODE=$ERROR_CODE_SUCCESS


#---------------------------
# functions
#---------------------------
GetAbsolutePath ()
{
    local DIR_NAME=$(dirname "$1")
    pushd "$DIR_NAME" > /dev/null
    local RESULT_PATH=$PWD
    popd > /dev/null
    echo $RESULT_PATH
}

GetPathFromLink ()
{
    local RESULT_PATH=$(dirname $([ -L "$1" ] && readlink -n "$1"))
    echo $RESULT_PATH
}

CreateLink ()
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
        echo "**** target file $1 does not exist"
        LINK_RESULT=$( echo false )
    fi
    $LINK_RESULT
}

DeleteLink ()
{
    if [ $# -ne 1 ]; then
        echo "ERROR: invalid number of parameters"
        echo "DeleteLink: requires only one parameter"
        false
    fi
    [ $TRACE != 0 ] && echo "\$1 = $1"
    LINKED_TO="$(GetPathFromLink $1)/$(basename "$1")"
    #delete previous link association if needed
    [ -L "$1" ] && unlink "$1"
    LINK_RESULT=$([ $? == 0 ] && echo true || echo false )
    echo "[$LINK_RESULT]: $1 -> $LINKED_TO"
    $LINK_RESULT
}

IsParameterHelp ()
{
    echo "-> IsParameterHelp ($@)"
    local NUMBER_OF_PARAMETERS=$1
    local PARAMETER=$2
    if [[ $NUMBER_OF_PARAMETERS -eq 1 && $PARAMETER == "--help" ]]; then
        echo "<- IsParameterHelp (TRUE)"
        return $TRUE
    else
        echo "<- IsParameterHelp (FALSE)"
        return $FALSE
    fi
}

CheckNumberOfParameters ()
{
    echo "-> CheckNumberOfParameters ($@)"
    local LCL_EXPECTED_NUMBER_OF_PARAMS=$1
    local LCL_ALL_PARAMS=($@)
    local LCL_PARAMETERS_PASSED_IN=(${LCL_ALL_PARAMS[@]:1:$#})
    if [ $LCL_EXPECTED_NUMBER_OF_PARAMS -ne ${#LCL_PARAMETERS_PASSED_IN[@]} ]; then
        echo "ERROR: invalid number of parameters."
        echo "  expected number:  $LCL_EXPECTED_NUMBER_OF_PARAMS"
        echo "  passed in number: ${#LCL_PARAMETERS_PASSED_IN[@]}"
        echo "  parameters passed in: ${LCL_PARAMETERS_PASSED_IN[@]}"
        echo "<- CheckNumberOfParameters (FALSE)"
        return $FALSE
    else
        echo "<- CheckNumberOfParameters (TRUE)"
        return $TRUE
    fi
}

IsPredefinedParameterValid ()
{
    echo "-> IsPredefinedParameterValid ($@)"
    local LCL_MATCH_FOUND=$FALSE
    local LCL_VALID_PARAMETERS=""
    local LCL_PARAMETER=$1
    shift
    local PARAMETER_ARRAY=("$@")
    # echo "\$LCL_PARAMETER = $LCL_PARAMETER"
    for element in "${PARAMETER_ARRAY[@]}";
    do
        if [ $LCL_PARAMETER == $element ]; then
            LCL_MATCH_FOUND=$TRUE
        fi
        LCL_VALID_PARAMETERS="$LCL_VALID_PARAMETERS $element,"
        # echo "VALID PARAMS = $element"
    done

    if [ $LCL_MATCH_FOUND -eq $TRUE ]; then
        echo "<- IsPredefinedParameterValid (TRUE)"
        return $TRUE
    else
        echo -e "${RED}ERROR: Invalid parameter:${NC} ${PURPLE}$PARAMETER${NC}"
        echo -e "${RED}Valid Parameters: $LCL_VALID_PARAMETERS ${NC}"
        echo "<- IsPredefinedParameterValid (FALSE)"
        return $FALSE
    fi
}
