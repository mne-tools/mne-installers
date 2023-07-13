#!/bin/bash -ef

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
source ${SCRIPT_DIR}/extract_version.sh
export PYTHONUTF8=1
# enforce UTF-8 encoding when reading files even on Windows
echo "Running constructor recipe ${RECIPE_DIR} in verbose mode"
# PLATFORM_ARG and EXE_ARG can be used for building macOS ARM64 on Intel
constructor -v ${PLATFORM_ARG} ${EXE_ARG} ${RECIPE_DIR}
