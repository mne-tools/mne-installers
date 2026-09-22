#!/bin/bash -ef

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
source ${SCRIPT_DIR}/extract_version.sh
export PYTHONUTF8=1
# enforce UTF-8 encoding when reading files even on Windows

# Allow "./tools/build_local.sh --dry-run" to pass the --dry-run arg,
# and "--platform <subdir>" (e.g., osx-arm64, win-64) to solve for another OS
EXTRA_ARGS=""
PLATFORM=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) EXTRA_ARGS="$EXTRA_ARGS --dry-run";;
        --platform) PLATFORM="$2"; shift;;
    esac
    shift
done

if [[ "$PLATFORM" != "" ]]; then
    # constructor cannot even dry-run a non-native installer, so approximate its solve
    # with "conda create --dry-run" using faked virtual packages. This is for debugging
    # only: it is not an exact match for constructor's solve on CI, which is what counts.
    echo "::group::Approximately solving recipe ${RECIPE_DIR} specs for ${PLATFORM}"
    ARGS=()
    while IFS= read -r LINE; do ARGS+=("$LINE"); done < <(python -c "
import sys
from constructor.construct import parse
info = parse(sys.argv[1] + '/construct.yaml', sys.argv[2])
print('\n'.join(f'--channel\n{channel}' for channel in info['channels']))
print('\n'.join(info['specs']))
" "${RECIPE_DIR}" "${PLATFORM}")
    # Flexible priority like CI; strict would hide the Spyder dev labels behind conda-forge
    set -x
    CONDA_SUBDIR=${PLATFORM} CONDA_CHANNEL_PRIORITY=flexible CONDA_OVERRIDE_CUDA= \
        CONDA_OVERRIDE_OSX=15.5 CONDA_OVERRIDE_WIN=10 CONDA_OVERRIDE_GLIBC=2.35 \
        conda create --dry-run --override-channels --prefix "$(mktemp -u)" "${ARGS[@]}"
    set +x
    echo "::endgroup::"
    exit 0
fi

echo "::group::Running constructor recipe ${RECIPE_DIR} in verbose mode"
set -x
constructor $EXTRA_ARGS -v ${RECIPE_DIR}
echo "::endgroup::"
