#!/bin/bash -ef

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
source ${SCRIPT_DIR}/extract_version.sh
# TODO: Once the forked conda constructor is available on mac-arm64 natively,
# we should remove the second part of this conditional
if [[ $MACHINE == "macOS" && $PYMACHINE != "arm64" ]]; then
    CONSTRUCTOR_DIR=${CONDA_PREFIX}/lib/python${PYSHORT}/site-packages/constructor
    PATCHFILE=${SCRIPT_DIR}/../assets/constructor_macOS.patch
    if ! patch -Rd ${CONSTRUCTOR_DIR} -p1 -s -f --dry-run < $PATCHFILE; then
        echo "Patching constructor ${CONSTRUCTOR_DIR}..."
        patch -Nd ${CONSTRUCTOR_DIR} -p1 < $PATCHFILE
    else
        echo "Constructor already patched: ${CONSTRUCTOR_DIR}"
    fi
fi
