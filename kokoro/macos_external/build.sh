#!/bin/bash

# Fail on any error.
set -ex

mkdir -p $1

function absname {
  echo $(cd "$1" && pwd)
}

BUILD_ROOT=$PWD
BUILD_OUT=$1
SRC=$(absname "$(dirname "${BASH_SOURCE[0]}")")
BIN=$SRC/../../bin


CURL="curl -fksLS --http1.1 --retry 3"

# Get Bazel
BAZEL_VERSION=4.2.0
$CURL -O https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-darwin-x86_64.sh
echo "ee86e5bcf8661af7a08ea49378db1977bedb9a391841158b0610d27c4f601ad1  bazel-${BAZEL_VERSION}-installer-darwin-x86_64.sh" | shasum --check
mkdir bazel
sh bazel-${BAZEL_VERSION}-installer-darwin-x86_64.sh --prefix=$PWD/bazel


export DEVELOPER_DIR=/Applications/Xcode_12.4.app/Contents/Developer

function run_bazel {
  ACTION=$1
  shift

  $BUILD_ROOT/bazel/bin/bazel \
      --output_base="${TMP}/bazel_out" \
      $ACTION \
      --show_timestamps \
      $@
}

run_bazel build //:hello

# Make a dmg file.
python3 -m pip install --upgrade --user dmgbuild pyobjc-framework-Quartz
~/.local/bin/dmgbuild ../../logo agi-1-macos.dmg

echo "Done!"

