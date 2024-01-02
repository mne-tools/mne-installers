#!/bin/bash -ef

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
export RECIPE_DIR=${SCRIPT_DIR}/../recipes/mne-python
export MNE_INSTALLER_VERSION=$(grep "^version: .*$" ${RECIPE_DIR}/construct.yaml | cut -d' ' -f2)
export PYSHORT=$(python -c "import sys; print('.'.join(map(str, sys.version_info[:2])))")
UNAME="$(uname -s)"
if [[ "$1" != "" ]] && [[ "$1" != "--dry-run" ]]; then
    MACHINE="$1"
else
    case "${UNAME}" in
        Linux*)      MACHINE=Linux;;
        Darwin*)     MACHINE=macOS;;
        MINGW64_NT*) MACHINE=Windows;;
        MSYS_NT*)    MACHINE=Windows;;
        *)           MACHINE="UNKNOWN:${UNAME}"
    esac
fi
if [[ "$MACHINE" != "macOS" && "$MACHINE" != "Linux" && "$MACHINE" != "Windows" ]]; then
    echo "Unknown machine: ${MACHINE}"
    exit 1
fi
export MACHINE=$MACHINE  # Linux, macOS, Windows, as specified above
export PYMACHINE=$(python -c "import platform; print(platform.machine())")  # x86_64, AMD64, arm64, etc.

if [[ "$PYMACHINE" == "AMD64" ]]; then
    ARTIFACT_ID_SUFFIX="x86_64"
else
    ARTIFACT_ID_SUFFIX=$PYMACHINE
fi

# macOS artifact naming
if [[ ${MNE_CROSSCOMPILE_ARCH} == 'arm64' ]]; then  # This env var only really gets set on GitHub Actions
    MACOS_SUFFIX="M1"
    ARTIFACT_ID_SUFFIX="arm64"
elif [[ "$MACHINE" == "macOS" && "$PYMACHINE" == "x86_64" ]]; then
    MACOS_SUFFIX="Intel"
elif [[ "$MACHINE" == "macOS" && "$PYMACHINE" == "arm64" ]]; then
    MACOS_SUFFIX="M1"
fi

if [[ "$MACHINE" == "macOS" ]]; then
    MNE_INSTALL_PREFIX="/Applications/MNE-Python/${MNE_INSTALLER_VERSION}/.mne-python"
    MNE_INSTALLER_NAME="MNE-Python-${MNE_INSTALLER_VERSION}-${MACHINE}_${MACOS_SUFFIX}.pkg"
    MNE_ACTIVATE="$MNE_INSTALL_PREFIX/bin/activate"
elif [[ "$MACHINE" == "Linux" ]]; then
    MNE_INSTALL_PREFIX="$HOME/mne-python/${MNE_INSTALLER_VERSION}"
    MNE_INSTALLER_NAME="MNE-Python-${MNE_INSTALLER_VERSION}-${MACHINE}.sh"
    MNE_ACTIVATE="$MNE_INSTALL_PREFIX/bin/activate"
else
    MNE_INSTALL_PREFIX="$HOME/mne-python/$MNE_INSTALLER_VERSION"
    MNE_INSTALLER_NAME="MNE-Python-${MNE_INSTALLER_VERSION}-${MACHINE}.exe"
    MNE_ACTIVATE="$MNE_INSTALL_PREFIX/Scripts/activate"
fi

export MNE_INSTALL_PREFIX="$MNE_INSTALL_PREFIX"
export MNE_INSTALLER_NAME="${MNE_INSTALLER_NAME}"
export MNE_ACTIVATE="$MNE_ACTIVATE"
export MNE_INSTALLER_ARTIFACT_ID="MNE-Python-${MACHINE}-${ARTIFACT_ID_SUFFIX}"
export MNE_MACHINE="$MACHINE"

echo "Version:     ${MNE_INSTALLER_VERSION} (Python=${PYSHORT})"
test "$MNE_INSTALLER_VERSION" != ""
test "$PYSHORT" != ""
test -d "$SCRIPT_DIR"
echo "Recipe:      ${RECIPE_DIR}"
test "$RECIPE_DIR" != ""
test -d "$RECIPE_DIR"
echo "Installer:   ${MNE_INSTALLER_NAME}"
test "$MNE_INSTALLER_NAME" != ""
echo "Artifact ID: ${MNE_INSTALLER_ARTIFACT_ID}"
test "$MNE_INSTALLER_ARTIFACT_ID" != ""
echo "Prefix:      ${MNE_INSTALL_PREFIX}"
test "$MNE_INSTALL_PREFIX" != ""
echo "Activate:    ${MNE_ACTIVATE}"
test "$MNE_ACTIVATE" != ""
echo "Machine:     ${MNE_MACHINE}"
test "$MNE_MACHINE" != ""

if [[ "$GITHUB_ACTIONS" == "true" ]]; then
    echo "MNE_INSTALLER_VERSION=${MNE_INSTALLER_VERSION}" >> $GITHUB_ENV
    echo "MNE_INSTALLER_NAME=${MNE_INSTALLER_NAME}" >> $GITHUB_ENV
    echo "MNE_INSTALLER_ARTIFACT_ID=${MNE_INSTALLER_ARTIFACT_ID}" >> $GITHUB_ENV
    echo "MNE_INSTALL_PREFIX=${MNE_INSTALL_PREFIX}" >> $GITHUB_ENV
    echo "RECIPE_DIR=${RECIPE_DIR}" >> $GITHUB_ENV
    echo "CONDA_SOLVER=libmamba" >> $GITHUB_ENV
    if [[ "$MNE_CROSSCOMPILE_ARCH" == "arm64" ]]; then
        echo "PLATFORM_ARG=--platform=osx-arm64" >> $GITHUB_ENV
        echo "EXE_ARG=--conda-exe=${CONDA_PREFIX}/standalone_conda/conda.exe" >> $GITHUB_ENV
    fi
    echo "MNE_ACTIVATE=${MNE_ACTIVATE}" >> $GITHUB_ENV
    echo "NSIS_SCRIPTS_RAISE_ERRORS=1" >> $GITHUB_ENV
    echo "MNE_MACHINE=${MNE_MACHINE}" >> $GITHUB_ENV
fi
