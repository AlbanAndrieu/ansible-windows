#!/bin/bash

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  echo "This script has to be sourced and not executed..."
  exit 1
fi

WORKING_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# source only if terminal supports color, otherwise use unset color vars
# shellcheck source=/dev/null
source "${WORKING_DIR}/step-0-color.sh"

function set_default {
  # Usage: set_default var_name default_value
  #
  # if variable is already set, it will only print value to screen,
  # if variable is not set, it will be set to default value
  #
  # Example:
  # set_default WORKSPACE $( pwd )
  local var_name=$1
  local var_value=${!var_name}
  local default_value=$2

  if [[ -z $var_value ]] || [[ $var_value == "" ]]; then
    echo -e "${yellow} ${not_ok} <${var_name}> is unset, using default value <${default_value}> ${NC}"
    export $var_name="$default_value"
  else
    echo -e "${green} ${ok} <${var_name}> is set to known value <${var_value}> ${NC}"
    export $var_name="$var_value"
  fi
}

function exec_with_comment {
  # Usage: exec_with_comment cmd comment
  #
  # Executes command and fails if the command fails,
  # prints additional debug / information during execution
  #
  # Example:
  # exec_with_comment "ls -la" "Listing current working directory"
  local cmd=$1
  local comment=$2

  echo -e "${cyan} ================== ${NC}"
  echo -e "${green} Executing command: ${NC}"
  echo -e "${green} ${comment} ${NC}"
  echo -e "${green} ${cmd} ${NC}"

  eval "$cmd"

  RC=$?
  if [ ${RC} -ne 0 ]; then
    echo ""
    echo -e "${red} ${head_skull} Executing command <${1}> failed with exit code ${RC} ${NC}"
    exit $RC
  else
    echo -e "${green} Command <${1}> completed successfully. ${NC}"
  fi
}
