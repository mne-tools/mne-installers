#!/bin/bash

set -eo pipefail

if [[ "$GITHUB_EVENT_NAME" != "pull_request" ]]; then
    pkgutil --check-signature ${MNE_INSTALLER_NAME} || exit 1
fi
# Now extract the package and check that the _conda binary is
# properly signed as well
pkgutil --expand-full ${MNE_INSTALLER_NAME} ./mne-extracted
DIR="./mne-extracted/prepare_installation.pkg/Payload/.mne-python"
echo "Checking ${DIR} exists"
test -d "$DIR"
ls -al "$DIR"
BINARY="${DIR}/_conda"
echo "Checking ${BINARY} exists"
test -e "${BINARY}"
echo "Checking ${BINARY} is signed"
/usr/bin/codesign -vd "${BINARY}"
echo "Checking entitlements of ${BINARY}"
/usr/bin/codesign --display --entitlements - "${BINARY}"
rm -rf ./mne-extracted
