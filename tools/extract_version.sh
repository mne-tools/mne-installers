#!/bin/bash -ef

VER=$(cat assets/current_version.txt)
test VER != ""
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
export MNE_INSTALLER_VERSION=$(head -n 1 recipes/mne-python_${VER}/construct.yaml | cut -d' ' -f2)
export RECIPE_DIR=${SCRIPT_DIR}/../recipes/mne-python_$(echo $MNE_INSTALLER_VERSION | cut -d . -f-2)
export PYSHORT=$(python -c "import sys; print('.'.join(map(str, sys.version_info[:2])))")
UNAME="$(uname -s)"
case "${UNAME}" in
    Linux*)      MACHINE=Linux;;
    Darwin*)     MACHINE=macOS;;
    MINGW64_NT*) MACHINE=Windows;;
    *)           MACHINE="UNKNOWN:${UNAME}"
esac
if [[ "$MACHINE" != "macOS" && "$MACHINE" != "Linux" && "$MACHINE" != "Windows" ]]; then
    echo "Unknown machine: ${UNAME}"
    exit 1
fi
export MACHINE=$MACHINE
export PYMACHINE=$(python -c "import platform; print(platform.machine())")
ARTIFACT_SUFFIX=$PYMACHINE
MACOS_SUFFIX="Intel"
# This env var only really gets set on GitHub
if [[ ${CROSSCOMPILE_ARCH} == 'arm64' ]]; then
    MACOS_SUFFIX="M1"
    ARTIFACT_SUFFIX="arm64"
fi
MNE_INSTALLER_NAME="MNE-Python-${MACHINE}"
if [[ "$MACHINE" == "macOS" ]]; then
    MNE_INSTALLER_NAME="${MNE_INSTALLER_NAME}_${MACOS_SUFFIX}.pkg"
elif [[ "$MACHINE" == "Linux" ]]; then
    MNE_INSTALLER_NAME="${MNE_INSTALLER_NAME}.sh"
else
    MNE_INSTALLER_NAME="${MNE_INSTALLER_NAME}.exe"
fi
export MNE_INSTALLER_NAME="${MNE_INSTALLER_NAME}"
export MNE_ARTIFACT_NAME="MNE-Python-${MACHINE}-${ARTIFACT_SUFFIX}"