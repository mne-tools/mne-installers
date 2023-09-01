#!/bin/bash

# This is used to initialize the bash prompt on macOS and Linux.

if [[ -f ~/.bashrc ]] && [[ ${OSTYPE} != 'darwin'* ]]; then
    source ~/.bashrc
fi
source /home/conda/feedstock_root/build_artifacts/mne-python_1692127656949/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_/bin/activate
echo "Using $(python --version) from $(which python)"
echo "This is $(mne --version)"
