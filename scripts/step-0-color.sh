#!/bin/bash
#set -xv

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  echo "This script has to be sourced and not executed..."
  exit 1
fi

NO_COLOR=${NO_COLOR:-false}

# below give the number of supported colors
# tput colors

if [ "${NO_COLOR}" == "false" ]; then
  export bold="\033[01m"
  export underline="\033[04m"
  export blink="\033[05m"

  export black="\033[30m"
  export red="\033[31m"
  export green="\033[32m"
  export yellow="\033[33m"
  export blue="\033[34m"
  export magenta="\033[35m"
  export cyan="\033[36m"
  export ltgray="\033[37m"

  if [ "$(uname -s)" == "Linux" ]; then
    export double_arrow='\xC2\xBB'
    export head_skull='\xE2\x98\xA0'
    export happy_smiley='\xE2\x98\xBA'
    # shellcheck disable=SC2034
    export reverse_exclamation='\u00A1'
    export circle='\xD2\x89'
  fi

fi

export NC="\033[0m"
