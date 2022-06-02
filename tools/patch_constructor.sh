#!/bin/bash -ef

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
source ${SCRIPT_DIR}/extract_version.sh

if [[ $MACHINE == "macOS" ]]; then
    CONSTRUCTOR_DIR=${CONDA_PREFIX}/lib/python${PYSHORT}/site-packages/constructor
    PATCHFILE_COMMON=${SCRIPT_DIR}/../assets/constructor_macOS_common.patch
    PATCHFILE_I386=${SCRIPT_DIR}/../assets/constructor_macOS_i386.patch
    PATCHFILE_ARM64=${SCRIPT_DIR}/../assets/constructor_macOS_arm64.patch

    if ! patch -Rd ${CONSTRUCTOR_DIR} -p1 -s -f --dry-run < $PATCHFILE_COMMON; then
        echo "Patching constructor ${CONSTRUCTOR_DIR}..."
        patch -Nd ${CONSTRUCTOR_DIR} -p1 < $PATCHFILE_COMMON

        if [[ $PYMACHINE != "arm64" ]]; then
            patch -Nd ${CONSTRUCTOR_DIR} -p1 < $PATCHFILE_ARM64
        else
            patch -Nd ${CONSTRUCTOR_DIR} -p1 < $PATCHFILE_I386
        fi
    else
        echo "Constructor already patched: ${CONSTRUCTOR_DIR}"
    fi
fi
