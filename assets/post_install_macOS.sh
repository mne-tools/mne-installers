#!/bin/bash

# This script must be marked +x to work correctly with the installer!

set -eo pipefail

logger -p 'install.info' "ℹ️ Running the custom MNE-Python post-install script."

# This doesn't appear to be working: even when the installer is run through
# sudo, SUDO_USER is unset. Leave it here for reference:
# # If we're running through sudo, get user name of the user who invoked sudo
# [ $SUDO_USER ] && USER=$SUDO_USER

# ☠️ This is ugly and bound to break, but seems to do the job for now. ☠️
# Don't name the variable USER, as this one is already set.
USER_FROM_HOMEDIR=`basename $HOME`
MNE_VERSION=`basename "$PREFIX" | cut -d "_" -f2-`
logger -p 'install.info' "📓 USER_FROM_HOMEDIR=$USER_FROM_HOMEDIR"
logger -p 'install.info' "📓 DSTROOT=$DSTROOT"
logger -p 'install.info' "📓 PREFIX=$PREFIX"
logger -p 'install.info' "📓 MNE_VERSION=$MNE_VERSION"

# Guess whether it's a system-wide or only-me install
if [[ "$PREFIX" == "/Library/"* ]]; then
    APP_DIR=/Applications
    PERMS="sudo"
else
    APP_DIR="$HOME"/Applications
    PERMS=""
fi
MNE_APP_DIR="$APP_DIR/MNE-Python $MNE_VERSION"
logger -p 'install.info' "📓 MNE_APP_DIR=$MNE_APP_DIR"

logger -p 'install.info' "ℹ️ Moving root MNE .app bundles from $APP_DIR to $MNE_APP_DIR."
$PERMS mkdir -p "$MNE_APP_DIR"
$PERMS mv "$APP_DIR"/*\(MNE\).app "$MNE_APP_DIR"/

logger -p 'install.info' "ℹ️ Fixing permissions of MNE .app bundles in $MNE_APP_DIR: new owner will be ${USER_FROM_HOMEDIR}."
$PERMS chown -R "$USER_FROM_HOMEDIR" "$MNE_APP_DIR"

MNE_ICON_PATH="$PREFIX/Menu/mne.png"
logger -p 'install.info' "ℹ️ Setting custom folder icon for $MNE_APP_DIR to $MNE_ICON_PATH."
osascript \
    -e 'set destPath to "'"${MNE_APP_DIR}"'"' \
    -e 'set iconPath to "'"${MNE_ICON_PATH}"'"' \
    -e 'use framework "Foundation"' \
    -e 'use framework "AppKit"' \
    -e "set imageData to (current application's NSImage's alloc()'s initWithContentsOfFile:iconPath)" \
    -e "(current application's NSWorkspace's sharedWorkspace()'s setIcon:imageData forFile:destPath options: 0)"

# Use Intel packages if the Python binary is x84_64, i.e. not native Apple Silicon
# (This also applies to an Intel binary running on Apple Silicon through Rosetta)
# https://conda-forge.org/docs/user/tipsandtricks.html#installing-apple-intel-packages-on-apple-silicon
DSTBIN=${PREFIX}/bin
PYTHON_PLATFORM=$(${DSTBIN}/conda run python -c "import platform; print(platform.machine())")
PYSHORT=$($DSTBIN/conda run python -c "import sys; print('.'.join(map(str, sys.version_info[:2])))")
if [ "${PYTHON_PLATFORM}" == "x86_64" ]; then
    logger -p 'install.info' "ℹ️ Configuring conda to only use Intel packages"
    ${PREFIX}/bin/conda env config vars set CONDA_SUBDIR=osx-64
fi

logger -p 'install.info' "ℹ️ Configuring Python to ignore user-installed local packages."
${DSTBIN}/conda env config vars set PYTHONNOUSERSITE=1

logger -p 'install.info' "ℹ️ Disabling mamba package manager banner."
${DSTBIN}/conda env config vars set MAMBA_NO_BANNER=1

logger -p 'install.info' "ℹ️ Setting libmama as the conda solver."
${DSTBIN}/conda config --set solver libmamba

logger -p 'install.info' "ℹ️ Configuring Matplotlib to use the Qt backend by default."
sed -i '.bak' "s/##backend: Agg/backend: qtagg/" ${PREFIX}/lib/python${PYSHORT}/site-packages/matplotlib/mpl-data/matplotlibrc

logger -p 'install.info' "ℹ️ Pinning BLAS implementation to OpenBLAS."
echo "libblas=*=*openblas" >> ${PREFIX}/conda-meta/pinned

logger -p 'install.info' "ℹ️ Fixing permissions of entire conda environment for user=${USER_FROM_HOMEDIR}."
chown -R "$USER_FROM_HOMEDIR" "${PREFIX}"

logger -p 'install.info' "ℹ️ Running mne sys_info."
${DSTBIN}/conda run mne sys_info || true

logger -p 'install.info' "ℹ️ Opening in Finder ${MNE_APP_DIR}/."
open -R "${MNE_APP_DIR}/"
