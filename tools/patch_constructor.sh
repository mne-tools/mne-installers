#!/bin/bash -ef

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
source ${SCRIPT_DIR}/extract_version.sh
if [[ $MACHINE == "macOS" ]]; then
    CONSTRUCTOR_DIR=${CONDA_PREFIX}/lib/python${PYSHORT}/site-packages/constructor
    echo "Patching constructor ${CONSTRUCTOR_DIR}..."
    patch -d ${CONSTRUCTOR_DIR} -p1 < ${SCRIPT_DIR}/../assets/constructor_macOS.patch
fi
