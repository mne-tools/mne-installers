echo ℹConfiguring Python to ignore user-installed local packages.
echo {"env_vars": {"PYTHONNOUSERSITE": "1"}} >> "%PREFIX%\conda-meta\state"
echo ℹRunning mne sys_info.
"%PREFIX%\bin\conda" run mne sys_info
