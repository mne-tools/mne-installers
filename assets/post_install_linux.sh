#!/bin/bash

# This script must be marked +x to work correctly with the installer!

# It works around a bug in menuinst.

set -e

echo "Fixing menu shortcuts."

cd "$HOME/.local/share/applications"
for f in ./MNE-Python*.desktop
do
    sed "s/Terminal=True/Terminal=true" $f > $f
    sed "s/Terminal=False/Terminal=false" $f > $f
done
