#!/bin/bash -ef

echo "::group::Running conda-build recipe mne-installer-menu"
set -x
conda-build mne-installer-menu --no-anaconda-upload --croot conda-bld
set +x
echo "::endgroup::"
