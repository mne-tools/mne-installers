#!/bin/bash

set -eo pipefail

MNE_JSON="${MNE_INSTALLER_NAME}.env.json"
echo "Checking file size for ${MNE_JSON}"
ACTUAL=$(du -k "${MNE_JSON}" | cut -f1)
echo "Actual size:  ${ACTUAL} KB"
echo "Minimum size: 200 KB"
test "$ACTUAL" -gt 200
