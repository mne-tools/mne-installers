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

logger -p 'install.info' "ℹ️ Configuring Python to ignore user-installed local packages"
${DSTBIN}/conda env config vars set PYTHONNOUSERSITE=1

logger -p 'install.info' "ℹ️ Disabling mamba package manager banner"
${DSTBIN}/conda env config vars set MAMBA_NO_BANNER=1

logger -p 'install.info' "ℹ️ Configuring Matplotlib to use the Qt backend by default"
sed -i '.bak' "s/##backend: Agg/backend: qtagg/" ${PREFIX}/lib/python${PYSHORT}/site-packages/matplotlib/mpl-data/matplotlibrc

logger -p 'install.info' "ℹ️ Pinning BLAS implementation to OpenBLAS"
echo "libblas=*=*openblas" >> ${PREFIX}/conda-meta/pinned

logger -p 'install.info' "Fixing permissions of entire conda environment for user=${USER_FROM_HOMEDIR}"
# chown -R $USER_FROM_HOMEDIR "${PREFIX}"

logger -p 'install.info' "Running mne sys_info"
${DSTBIN}/conda run mne sys_info || true

logger -p 'install.info' "Opening in Finder ${PREFIX}"
open -R "${PREFIX}"
