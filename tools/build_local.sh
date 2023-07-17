#!/bin/bash -ef

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
source ${SCRIPT_DIR}/extract_version.sh
echo "Building installer locally"
echo "--------------------------"
echo "Version:      ${MNE_INSTALLER_VERSION}"
echo "Recipe:       ${RECIPE_DIR}"
echo "OS:           ${MACHINE}"
echo "Machine:      ${PYMACHINE}"
echo "PLATFORM_ARG: ${PLATFORM_ARG}"
echo "EXE_ARG:      ${EXE_ARG}"
${SCRIPT_DIR}/run_constructor.sh
