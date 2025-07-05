#!/bin/bash -ef

echo "::group::Running conda-build recipe mne-installer-menu"
conda-build mne-installer-menu --no-anaconda-upload --croot conda-bld
echo "::endgroup::"
