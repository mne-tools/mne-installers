#!/bin/bash

set -o pipefail

TO=20s
KILL_AFTER=10s

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

# Spyder does not exit on SIGTERM once its language server and kernel are up, so
# without -k the timeout process itself hangs forever waiting for it (this wedged
# the macOS Intel runner). -k escalates to SIGKILL, which exits 137 rather than 124.
echo "Running Spyder with a timeout of $TO ($TIMEOUT):"
$TIMEOUT -k $KILL_AFTER $TO spyder < /dev/null
RESULT=$?
if [[ $RESULT -eq 124 || $RESULT -eq 137 ]]; then
    echo "Spyder succeeded with timeout (code $RESULT)"
else
    echo "Spyder failed with error code $RESULT (should be 124 or 137 for timeout)"
    exit 1
fi
