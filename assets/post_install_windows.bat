echo ℹSetting permissions on the Python installation.
takeown /f %PREFIX% /r /d y

echo ℹConfiguring Python to ignore user-installed local packages.
"%PREFIX%\bin\conda" env config vars set PYTHONNOUSERSITE=1

echo ℹDisabling mamba package manager banner.
"%PREFIX%\bin\conda" env config vars set MAMBA_NO_BANNER=1

echo ℹSetting libmama as the conda solver.
"%PREFIX%\bin\conda" config --set solver libmamba

echo ℹPinning BLAS implementation to OpenBLAS
echo "libblas=*=*openblas" >> "%PREFIX%\bin\conda\conda-meta\pinned"

echo ℹRunning mne sys_info.
"%PREFIX%\bin\conda" run mne sys_info
