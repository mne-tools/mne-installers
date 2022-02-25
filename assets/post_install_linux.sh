#!/bin/bash

# This script must be marked +x to work correctly with the installer!

# It works around a bug in menuinst.

set -e

echo "ℹ️ Fixing menu shortcuts."

cd "$HOME/.local/share/applications"
for f in ./MNE-Python*.desktop
do
    sed -i "s/Terminal=True/Terminal=true/" $f
    sed -i "s/Terminal=False/Terminal=false/" $f
done

echo "ℹ️ Configuring Python to ignore user-installed local packages."
echo '{"env_vars": {"PYTHONNOUSERSITE": "1"}}' >> "${PREFIX}/conda-meta/state"
