#!/bin/bash -ef

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
source ${SCRIPT_DIR}/extract_version.sh
if [[ $MACHINE == "macOS" ]]; then
    CONSTRUCTOR_DIR=${CONDA_PREFIX}/lib/python${PYSHORT}/site-packages/constructor
    PATCHFILE=${SCRIPT_DIR}/../assets/constructor_macOS.patch
    if ! patch -Rd ${CONSTRUCTOR_DIR} -p1 -s -f --dry-run < $PATCHFILE; then
        echo "Patching constructor ${CONSTRUCTOR_DIR}..."
        patch -Nd ${CONSTRUCTOR_DIR} -p1 < $PATCHFILE
    else
        echo "Constructor already patched: ${CONSTRUCTOR_DIR}"
    fi
fi
