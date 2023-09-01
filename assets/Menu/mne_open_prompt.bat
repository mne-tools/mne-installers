:: This is used to initialize the bash prompt on Windows.
@ECHO OFF

call %/home/conda/feedstock_root/build_artifacts/mne-python_1692127656949/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_%\Scripts\Activate.bat
FOR /F "tokens=*" %%g IN ('python --version') do (SET PYVER=%%g)
FOR /F "tokens=*" %%g IN ('where python') do (SET PYPATH=%%g)
FOR /F "tokens=*" %%g IN ('mne --version') do (SET MNEVER=%%g)

ECHO Using %PYVER% from %PYPATH%
ECHO This is %MNEVER%
