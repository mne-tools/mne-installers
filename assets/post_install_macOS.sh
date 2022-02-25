#!/bin/bash

# This script must be marked +x to work correctly with the installer!

set -e

logger -p 'install.info' "ℹ️ Running the custom MNE-Python post-install script."

# This doesn't appear to be working: even when the installer is run through
# sudo, SUDO_USER is unset. Leave it here for reference:
# # If we're running through sudo, get user name of the user who invoked sudo
# [ $SUDO_USER ] && USER=$SUDO_USER

# ☠️ This is ugly and bound to break, but seems to do the job for now. ☠️
# Don't name the variable USER, as this one is already set.
USER_FROM_HOMEDIR=`basename $HOME`

logger -p 'install.info' "ℹ️ Fixing permissions of MNE .app bundles in ${HOME}/Applications: new owner will be ${USER_FROM_HOMEDIR}"
chown -R $USER_FROM_HOMEDIR "${HOME}"/Applications/MNE*.app

logger -p 'install.info' "ℹ️ Moving MNE .app bundles from ${HOME}/Applications to /Applications"
mv "${HOME}"/Applications/MNE*.app /Applications/

# https://conda-forge.org/docs/user/tipsandtricks.html#installing-apple-intel-packages-on-apple-silicon
logger -p 'install.info' "ℹ️ Configuring conda to only use Intel packages -- even on Apple Silicon; and configuring Python to ignore user-installed local packages"
echo "{\"env_vars\": {\"CONDA_SUBDIR\": \"osx-64\", \"PYTHONNOUSERSITE\": \"1\"}}" >> "${DSTROOT}/mne-python_1.0.0_0/conda-meta/state"

logger -p 'install.info' "Fixing permissions of entire conda environment"
chown -R $USER_FROM_HOMEDIR "${DSTROOT}/mne-python_1.0.0_0"
