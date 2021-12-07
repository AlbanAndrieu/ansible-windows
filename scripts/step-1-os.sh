#!/bin/bash
#set -xv

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  echo "This script has to be sourced and not executed..."
  exit 1
fi

case "$OSTYPE" in
linux*) export SYSTEM=LINUX ;;
darwin*) export SYSTEM=OSX ;;
win*) export SYSTEM=Windows ;;
cygwin*) export SYSTEM=Cygwin ;;
msys*) export SYSTEM=MSYS ;;
bsd*) export SYSTEM=BSD ;;
solaris*) export SYSTEM=SOLARIS ;;
*) export SYSTEM=UNKNOWN ;;
esac
echo "SYSTEM : ${SYSTEM}"

if [ -f /etc/os-release ]; then
  # freedesktop.org and systemd
  . /etc/os-release
  OS=$NAME
  VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
  # linuxbase.org
  OS=$(lsb_release -si)
  VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
  # For some versions of Debian/Ubuntu without lsb_release command
  . /etc/lsb-release
  OS=$DISTRIB_ID
  VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
  # Older Debian/Ubuntu/etc.
  OS=Debian
  VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
  # Older SuSE/etc.
  ...
elif [ -f /etc/redhat-release ]; then
  # Older Red Hat, CentOS, Docker etc.
  #less /etc/redhat-release
  OS=$(uname -s) # Linux
  VER=$(uname -r)
else
  # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
  OS=$(uname -s)
  VER=$(uname -r)
fi
echo "OS : ${OS}"
echo "VER : ${VER}"
