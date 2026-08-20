#!/bin/bash

set -o pipefail

TO=20s

# macOS has no GNU timeout; CI installs coreutils, which provides gtimeout
if command -v gtimeout &> /dev/null; then
    TIMEOUT=gtimeout
else
    TIMEOUT=timeout
fi

# spyder dies without this set on Windows
SYSTEM=$(expr substr $(uname -s) 1 10)
echo "System: $SYSTEM"
if [ "$SYSTEM" == "MINGW64_NT" ]; then
    echo "Setting HOMEPATH to $(pwd)"
    export HOMEPATH=$(pwd)
fi

echo "which spyder: $(which spyder)"

# Cheap non-GUI smoke test first, so an import/entry-point problem is easy to
# tell apart from a GUI startup problem below
spyder -h > /dev/null || exit 1
spyder --paths || exit 1

echo "Running Spyder with a timeout of $TO ($TIMEOUT):"
$TIMEOUT $TO spyder
RESULT=$?
if [[ $RESULT -eq 124 ]]; then
    echo "Spyder succeeded with timeout"
else
    echo "Spyder failed with error code $RESULT (should be 124 for timeout)"
    exit 1
fi
