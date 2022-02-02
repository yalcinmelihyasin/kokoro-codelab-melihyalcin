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

if [ ! -f "$BIN/pkg/build.properties" ]; then
  echo Unable to find pkg/build.properties in $BIN
  exit 1
fi

rm -rf "$BUILD_OUT/dist"
mkdir -p "$BUILD_OUT/dist"
pushd "$BUILD_OUT/dist"
VERSION=$(awk -F= 'BEGIN {major=0; minor=0; micro=0}
                  /Major/ {major=$2}
                  /Minor/ {minor=$2}
                  /Micro/ {micro=$2}
                  END {print major"."minor"."micro}' $BIN/pkg/build.properties)

# Create a .app package
mkdir -p AGI.app/Contents/MacOS/jre
cp -r $BIN/pkg/* AGI.app/Contents/MacOS/
cp "$SRC/Info.plist" AGI.app/Contents/
"$SRC/copy_jre.sh" AGI.app/Contents/MacOS/jre

mkdir -p AGI.iconset AGI.app/Contents/Resources
for i in 512 256 128 64 32 16; do
  cp "$SRC/../../logo/logo_${i}.png" AGI.iconset/icon_${i}x${i}.png
  cp "$SRC/../../logo/logo_$((i*2)).png" AGI.iconset/icon_${i}x${i}\@2x.png
done
iconutil -c icns -o AGI.app/Contents/Resources/AGI.icns AGI.iconset

# Move the JRE's legal notices to the Resources folder, so signing doesn't complain.
# mkdir AGI.app/Contents/Resources/jre
# mv AGI.app/Contents/MacOS/jre/legal AGI.app/Contents/Resources/jre

# Create a zip file.
zip -r agi-$VERSION-macos.zip AGI.app

# Make a dmg file.
pip install --upgrade --user dmgbuild pyobjc-framework-Quartz
cp "$SRC"/background*.png .
cp "$SRC/dmg-settings.py" .
# Path to dmgbuild must match where pip installs it
~/Library/Python/3.7/bin/dmgbuild -s dmg-settings.py AGI agi-$VERSION-macos.dmg

# Copy the symbol file to the output.
[ -f "$BIN/cmd/gapir/cc/gapir.sym" ] && cp "$BIN/cmd/gapir/cc/gapir.sym" gapir-$VERSION-macos.sym

popd
