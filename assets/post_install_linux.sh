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
${PREFIX}/bin/conda env config vars set PYTHONNOUSERSITE=1

echo "ℹ️ Configuring Matplotlib to use the Qt5 backend by default."
${PREFIX}/bin/conda env config vars set MPLBACKEND=qt5agg

echo "ℹ️ Disabling mamba package manager banner."
${PREFIX}/bin/conda env config vars set MAMBA_NO_BANNER=1

echo "ℹ️ Running mne sys_info."
${PREFIX}/bin/conda run mne sys_info || true
