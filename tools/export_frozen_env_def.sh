#!/bin/bash

set -eo pipefail

source "${MNE_ACTIVATE}"
MNE_JSON="${MNE_INSTALLER_NAME}.env.json"
echo "Exporting frozen environment definition to ${MNE_JSON}"
echo "::group::Exporting frozen environment definition to ${MNE_JSON}"
conda list --json | tee ${MNE_JSON}
echo "::endgroup::"

echo "::group::Checking file size:"
ACTUAL=$(du -k "${MNE_JSON}" | cut -f1)
echo "Actual size:  ${ACTUAL} KB"
echo "Minimum size: 200 KB"
test "$ACTUAL" -gt 200
echo "::endgroup::"
