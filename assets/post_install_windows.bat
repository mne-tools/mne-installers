echo ℹConfiguring Python to ignore user-installed local packages.
"%PREFIX%\bin\conda" env config vars set PYTHONNOUSERSITE=1

echo ℹDisabling mamba package manager banner.
"%PREFIX%\bin\conda" env config vars set MAMBA_NO_BANNER=1

echo ℹRunning mne sys_info.
"%PREFIX%\bin\conda" run mne sys_info
