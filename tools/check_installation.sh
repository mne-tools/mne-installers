#!/bin/bash

set -eo pipefail
source "${MNE_ACTIVATE}"
conda info
mamba list

if [[ "$MNE_MACHINE" == "macOS" ]]; then
    echo "Testing that file permissions are set correctly (owned by "$USER", not "root".)"
    # https://unix.stackexchange.com/a/7733
    APP_DIR=/Applications/MNE-Python/${MNE_INSTALLER_VERSION}
    [ `ls -ld ${APP_DIR} | awk 'NR==1 {print $3}'` == "$USER" ] || exit 1
    echo "Check that the installed Python is, in fact, an Intel binary"
    python -c "import platform; assert platform.machine() == 'x86_64'" || exit 1
    echo "Checking we have all .app bundles in ${APP_DIR}:"
    ls -al /Applications/
    ls -al /Applications/MNE-Python
    ls -al ${APP_DIR}
    echo "Checking that there are 5 directories"
    test `ls -d ${APP_DIR}/*.app | wc -l` -eq 5 || exit 1
    echo "Checking that the custom icon was set on the MNE folder in ${APP_DIR}"
    test -f /Applications/MNE-Python/Icon$'\r' || exit 1
elif [[ "${{ runner.os }}" == "Linux" ]]; then
    echo "Checking that menu shortcuts were created …"
    pushd ~/.local/share/applications
    ls -l || exit 1
    echo "Checking for existence of .desktop files:"
    ls mne-python*.desktop || exit 1
    test `ls mne-python*.desktop | wc -l` -eq 5 || exit 1
    echo ""

    # … and patched to work around a bug in menuinst
    echo "Checking that incorrect Terminal entries have been removed"
    test `grep "Terminal=True"  mne-python*.desktop | wc -l` -eq 0 || exit 1
    test `grep "Terminal=False" mne-python*.desktop | wc -l` -eq 0 || exit 1
    echo ""

    echo "Checking that Terminal entries are correct…"
    test `grep "Terminal=true"  mne-python*.desktop | wc -l` -ge 1 || exit 1
    test `grep "Terminal=false" mne-python*.desktop | wc -l` -ge 1 || exit 1
    # Display their contents
    for f in mne-python*.desktop; do echo "📂 $f:"; cat "$f"; echo; done
    popd
fi
echo "Checking for pinned file..."
test -e "$MNE_INSTALL_PREFIX/conda-meta/pinned"
grep "openblas" "$MNE_INSTALL_PREFIX/conda-meta/pinned"

echo "Checking permissions..."
OWNER=`ls -ld "$(which python)" | awk '{print $3}'`
echo "Got OWNER=$OWNER, should be $(whoami)"
test "$OWNER" == "$(whoami)"

echo "Checking whether (Py)Qt is working"
LD_DEBUG=libs python -c "from PyQt5.QtWidgets import QApplication, QWidget; app = QApplication([])"

echo "Checking the deployed environment variables were set correctly upon environment activation"
mamba env config vars list
if [[ "$MNE_MACHINE" == "macOS" ]]; then
    python -c "import os; x = os.getenv('CONDA_SUBDIR'); assert x == 'osx-64', f'CONDA_SUBDIR ({repr(x)}) != osx-64'" || exit 1
fi
# TODO: broken on Windows!
if [[ "$MNE_MACHINE" != "Windows" ]]; then
    python -c "import os; x = os.getenv('PYTHONNOUSERSITE'); assert x == '1', f'PYTHONNOUSERSITE ({repr(x)}) != 1'" || exit 1
    python -c "import os; x = os.getenv('MAMBA_NO_BANNER'); assert x == '1', f'MAMBA_NO_BANNER ({repr(x)}) != 1'" || exit 1
fi

echo "Running MNE's sys_info"
mne sys_info

echo "Trying to import MNE and all additional packages included in the installer"
python -u tests/test_imports.py
python -u tests/test_gui.py
python -u tests/test_notebook.py
python -u tests/test_json_versions.py

echo "Checking that all packages are installed that MNE-Python devs would need"
python -u tests/test_dev_installed.py
