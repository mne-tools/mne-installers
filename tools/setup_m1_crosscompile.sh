#!/bin/bash -ef

if ! conda list conda-standalone | grep conda-standalone; then
    echo "Installing standalone"
    conda install -yc napari/label/bundle_tools_2 conda-standalone
fi
export PLATFORM_ARG="--platform=osx-arm64"
export EXE_ARG="--conda-exe=${CONDA_PREFIX}/standalone_conda/conda.exe"
