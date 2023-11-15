#!/bin/bash

set -eo pipefail

# Notarize the installer
xcrun notarytool submit ./${MNE_INSTALLER_NAME} \
    --wait \
    --apple-id=$APPLE_ID \
    --password=$APPLE_ID_PASSWORD \
    --team-id=$APPLE_TEAM_ID
# Staple the notarization certificate onto it
xcrun stapler staple ${MNE_INSTALLER_NAME}
