#!/bin/bash -ef

echo "::group::Running rattler-build recipe mne-installer-menu"
set -x
rattler-build build --recipe mne-installer-menu/recipe.yaml --output-dir conda-bld --no-build-id
set +x
echo "::endgroup::"
