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
chown -R $USER_FROM_HOMEDIR "${HOME}"/Applications/*\(MNE\).app

logger -p 'install.info' "ℹ️ Moving MNE .app bundles from ${HOME}/Applications to /Applications/MNE-Python"
mv "${HOME}"/Applications/*\(MNE\).app /Applications/MNE-Python/

logger -p 'install.info' "ℹ️ Setting custom folder icon for /Applications/MNE-Python"
osascript \
    -e 'set DSTROOT to system attribute "DSTROOT"' \
    -e 'set iconPath to DSTROOT & "/.mne-python/Menu/mne.png"' \
    -e 'use framework "Foundation"' \
    -e 'use framework "AppKit"' \
    -e "set imageData to (current application's NSImage's alloc()'s initWithContentsOfFile:iconPath)" \
    -e "(current application's NSWorkspace's sharedWorkspace()'s setIcon:imageData forFile:DSTROOT options: 0)"

# Use Intel packages if the Python binary is x84_64, i.e. not native Apple Silicon
# (This also applies to an Intel binary running on Apple Silicon through Rosetta)
# https://conda-forge.org/docs/user/tipsandtricks.html#installing-apple-intel-packages-on-apple-silicon
export PYTHON_PLATFORM=`${DSTROOT}/.mne-python/bin/conda run python -c "import platform; print(platform.machine())"`
if [ "${PYTHON_PLATFORM}" == "x86_64" ]; then
    logger -p 'install.info' "ℹ️ Configuring conda to only use Intel packages"
    ${DSTROOT}/.mne-python/bin/conda env config vars set CONDA_SUBDIR=osx-64
fi

logger -p 'install.info' "ℹ️ Configuring Python to ignore user-installed local packages"
${DSTROOT}/.mne-python/bin/conda env config vars set PYTHONNOUSERSITE=1

logger -p 'install.info' "ℹ️ Disabling mamba package manager banner"
${DSTROOT}/.mne-python/bin/conda env config vars set MAMBA_NO_BANNER=1

logger -p 'install.info' "Fixing permissions of entire conda environment"
chown -R $USER_FROM_HOMEDIR "${DSTROOT}/.mne-python"

logger -p 'install.info' "Opening ${DSTROOT} in Finder"
open -R "${DSTROOT}"
