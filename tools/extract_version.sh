#!/bin/bash -ef

VER=$(cat assets/current_version.txt)
test VER != ""
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
export VERSION=$(head -n 1 recipes/mne-python_${VER}/construct.yaml | cut -d' ' -f2)
export RECIPE_DIR=${SCRIPT_DIR}/../recipes/mne-python_$(echo $VERSION | cut -d . -f-2)
export RECIPE_DIR=$(realpath "${RECIPE_DIR}")
export PYSHORT=$(python -c "import sys; print(''.join(map(str, sys.version_info[:2])))")
UNAME="$(uname -s)"
case "${UNAME}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=macOS;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac
if [[ "$MACHINE" != "macOS" && "$MACHINE" != "Linux" ]]; then
    exit 1
fi
export MACHINE=$MACHINE
export PYARCH=$(python -c "import platform; print(platform.architecture()[0])")
