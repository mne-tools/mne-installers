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
export MNE_ARTIFACT_NAME="MNE-Python-$MACHINE-$PYMACHINE"
if [[ ${PYMACHINE} == 'x86_64' ]]; then
    export MACOS_SUFFIX="Intel"
else
    export MACOS_SUFFIX="M1"
fi
