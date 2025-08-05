#!/bin/bash

set -o pipefail

TO=20s

# spyder dies without this set on Windows
SYSTEM=$(expr substr $(uname -s) 1 10)
echo "System: $SYSTEM"
if [ "$SYSTEM" == "MINGW64_NT" ]; then
    echo "Setting HOMEPATH to $(pwd)"
    export HOMEPATH=$(pwd)
fi

echo "Running Spyder with a timeout of $TO:"
echo "which spyder: $(which spyder)"
timeout $TO spyder
RESULT=$?
if [[ $RESULT -eq 124 ]]; then
    echo "Spyder succeeded with timeout"
else
    echo "Spyder failed with error code $RESULT (should be 124 for timeout)"
    exit 1
fi
