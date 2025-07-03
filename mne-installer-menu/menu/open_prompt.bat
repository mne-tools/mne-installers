:: This is used to initialize the bash prompt on Windows.
@ECHO OFF

:: Workaround for
:: https://github.com/conda/conda/issues/14884
set "CONDA_EXE=#PREFIX#\Scripts\conda.exe"
call "#PREFIX#\Scripts\Activate.bat"
:: Find first Python on path.
FOR /F "tokens=*" %%g IN ('where python') do (
    SET PYPATH=%%g
    goto :endloop
)
:endloop
FOR /F "tokens=*" %%g IN ('python --version') do (SET PYVER=%%g)
FOR /F "tokens=*" %%g IN ('where python') do (SET PYPATH=%%g)
FOR /F "tokens=*" %%g IN ('mne --version') do (SET MNEVER=%%g)

ECHO Using %PYVER% from %PYPATH%
ECHO This is %MNEVER%
