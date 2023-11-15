#!/bin/bash

set -eo pipefail

source "${MNE_ACTIVATE}"
mamba list --json > ${MNE_INSTALLER_NAME}.env.json
cat ${MNE_INSTALLER_NAME}.env.json
