#!/bin/bash

set -eo pipefail

source "${MNE_ACTIVATE}"
echo "::group::Exporting frozen environment definition to ${MNE_INSTALLER_JSON_NAME}"
conda list --json | tee ${MNE_INSTALLER_JSON_NAME}
echo "::endgroup::"

echo "::group::Checking file size:"
ACTUAL=$(du -k "${MNE_INSTALLER_JSON_NAME}" | cut -f1)
echo "Actual size:  ${ACTUAL} KB"
echo "Minimum size: 200 KB"
test "$ACTUAL" -gt 200
echo "::endgroup::"
