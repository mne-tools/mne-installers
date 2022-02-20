#!/bin/sh

# This script must be marked +x to work correctly with the installer!

echo "Fixing permissions of MNE .app bundles: new owner will be ${USER}"
chown -R $USER/Applications/MNE*.app $USER

echo "Moving MNE .app bundles from ${USER}/Applications to /Applications"
mv $USER/Applications/MNE*.app /Applications

# https://conda-forge.org/docs/user/tipsandtricks.html#installing-apple-intel-packages-on-apple-silicon
echo "Configuring conda to only use Intel packages -- even on Apple Silicon -- when invoked by the user"
echo "{\"env_vars\": {\"CONDA_SUBDIR\": \"osx-64\"}}" >> "${DSTROOT}/mne-python_1.0.0_0/conda-meta/state"
chown "${DSTROOT}/mne-python_1.0.0_0/conda-meta/state" $USER
