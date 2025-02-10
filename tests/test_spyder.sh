#!/bin/bash

set -o pipefail

TO=20s
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
