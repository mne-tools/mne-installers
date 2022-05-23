#!/bin/bash -ef

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
source ${SCRIPT_DIR}/extract_version.sh
if [[ $MACHINE == "macOS" ]]; then
    echo "Patching constructor..."
    patch -d $CONDA_PREFIX/lib/python${PYSHORT}/site-packages/constructor -p1 < ${SCRIPT_DIR}/assets/constructor_macOS.patch
fi
