#!/bin/bash -ef

echo "::group::Running conda-build recipe mne-installer-menu"
set -x
conda-build mne-installer-menu --no-anaconda-upload --croot conda-bld
set +x
echo "::endgroup::"

echo "::group::Running conda-build recipe noqt5"
set -x
conda-build noqt5 --no-anaconda-upload --croot conda-bld
set +x
echo "::endgroup::"
