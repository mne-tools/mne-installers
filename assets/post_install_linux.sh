#!/bin/bash

# This script must be marked +x to work correctly with the installer!

set -eo pipefail

echo "ℹ️ Configuring Python to ignore user-installed local packages."
${PREFIX}/bin/conda env config vars set PYTHONNOUSERSITE=1

echo "ℹ️ Disabling mamba package manager banner."
${PREFIX}/bin/conda env config vars set MAMBA_NO_BANNER=1

echo "ℹ️ Pinning BLAS implementation to OpenBLAS"
echo "libblas=*=*openblas" >>${PREFIX}/conda-meta/pinned

echo "ℹ️ Running mne sys_info."
${PREFIX}/bin/conda run mne sys_info || true
