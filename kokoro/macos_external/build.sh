#!/bin/bash

# Fail on any error.
set -e

mkdir -p $1

function absname {
  echo $(cd "$1" && pwd)
}

BUILD_OUT=$1
SRC=$(absname "$(dirname "${BASH_SOURCE[0]}")")
BIN=$SRC/../../bin

# Make a dmg file.
python3 -m pip install --upgrade --user dmgbuild pyobjc-framework-Quartz
~/.local/bin/dmgbuild ../../logo agi-1-macos.dmg

echo "Done!"

