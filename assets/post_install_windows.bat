@ECHO OFF

echo Configuring Python to ignore user-installed local packages.
"%PREFIX%\Scripts\conda" env config vars set PYTHONNOUSERSITE=1

echo Disabling mamba package manager banner.
"%PREFIX%\Scripts\conda" env config vars set MAMBA_NO_BANNER=1

echo Pinning BLAS implementation to OpenBLAS.
echo libblas=*=*openblas >> "%PREFIX%\conda-meta\pinned"

echo Running mne sys_info.
"%PREFIX%\Scripts\conda" run mne sys_info -a || echo
