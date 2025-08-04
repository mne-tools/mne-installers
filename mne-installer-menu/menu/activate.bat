@ECHO OFF
:: Workaround for https://github.com/conda/conda/issues/14884
SET "MNE_SCRIPTS_DIR=%~dp0..\Scripts"
SET "CONDA_EXE=%MNE_SCRIPTS_DIR%\conda.exe"
CALL "%MNE_SCRIPTS_DIR%\Activate.bat"
