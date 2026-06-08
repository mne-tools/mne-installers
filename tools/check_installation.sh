#!/bin/bash

set -eo pipefail
echo "Running tests for MNE_MACHINE=${MNE_MACHINE} on CI_OS=${CI_OS}"
source "${MNE_ACTIVATE}"

echo "::group::conda info"
conda info
echo "::endgroup::"

echo "::group::conda info --envs"
conda info --envs
echo "::endgroup::"

echo "::group::conda list"
conda list
echo "::endgroup::"

echo "::group::pip list"
pip list
echo "::endgroup::"

N=100
echo "::group::package sizes (top $N)"
# https://stackoverflow.com/a/67976448/2175965
grep '"size":' ${CONDA_PREFIX}/conda-meta/*.json | sort -k3rn | sed -E 's/.*conda-meta\/(.+)\.json:.+"size": (.+),/\1 \2/g' > package_sizes.txt
head -n $N package_sizes.txt | column -t
echo "::endgroup::"

# Now that we have the package sizes listed, raise an error if the installer is too big
# (it will fail to attach to GH releases)
MAX_SIZE=2147483648
# I hate macOS sometimes
if [[ "$MNE_MACHINE" == "macOS" ]]; then
    SIZE_OPT="-f%c"
else
    SIZE_OPT="-c%s"
fi
ACTUAL_SIZE=$(stat $SIZE_OPT "$MNE_INSTALLER_NAME")
DIFF_SIZE=$((MAX_SIZE - ACTUAL_SIZE))
if [ "$ACTUAL_SIZE" -gt "$MAX_SIZE" ]; then
    echo "Error: Installer size ($ACTUAL_SIZE bytes) exceeds the maximum allowed size ($MAX_SIZE bytes) by $((-DIFF_SIZE)) bytes."
    exit 1
else
    echo "Installer size ($ACTUAL_SIZE bytes) is within the allowed limit ($MAX_SIZE bytes) by $DIFF_SIZE bytes."
fi

echo "::group::Platform specific tests for MNE_MACHINE=$MNE_MACHINE"
if [[ "$MNE_MACHINE" == "macOS" ]]; then
    echo "Testing that file permissions are set correctly (owned by "$USER", not "root".)"
    # https://unix.stackexchange.com/a/7733
    APP_DIR=/Applications/MNE-Python/${MNE_INSTALLER_VERSION}
    [ `ls -ld ${APP_DIR} | awk 'NR==1 {print $3}'` == "$USER" ] || exit 1

    echo "Checking that the installed Python is a binary for the correct CPU architecture"
    if [[ "$MACOS_ARCH" == "Intel" ]]; then
        python -c "import platform; assert platform.machine() == 'x86_64'" || exit 1
    elif [[ "$MACOS_ARCH" == "M1" ]]; then
        python -c "import platform; assert platform.machine() == 'arm64'" || exit 1
    fi

    echo "Checking we have all .app bundles in ${APP_DIR}:"
    ls -al /Applications/
    ls -al /Applications/MNE-Python
    ls -al ${APP_DIR}
    WANT=4
    echo "Checking that there are $WANT directories"
    test `ls -d ${APP_DIR}/*.app | wc -l` -eq $WANT || exit 1
    echo "Checking that the custom icon was set on the MNE folder in ${APP_DIR}"
    test -f /Applications/MNE-Python/Icon$'\r' || exit 1
    export SKIP_MNE_KIT_GUI_TESTS=1
elif [[ "$MNE_MACHINE" == "Linux" ]]; then
    echo "Checking that menu shortcuts were created …"
    pushd ~/.local/share/applications
    ls -l || exit 1
    WANT=5
    echo "Checking for existence of $WANT .desktop files:"
    ls mne-python*.desktop || exit 1
    test `ls mne-python*.desktop | wc -l` -eq $WANT || exit 1
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
    if [[ `grep "24.04" /etc/lsb-release` ]] || [[ `grep "20.04" /etc/lsb-release` ]]; then
        export SKIP_NOTEBOOK_TESTS=1
    fi
elif [[ "$MNE_MACHINE" != "Windows" ]]; then
    echo "Unknown MNE_MACHINE=$MNE_MACHINE, exiting with error"
    exit 1
fi
echo "::endgroup::"

echo "::group::Checking for pinned file..."
test -e "$MNE_INSTALL_PREFIX/conda-meta/pinned"
grep "openblas" "$MNE_INSTALL_PREFIX/conda-meta/pinned"
echo "::endgroup::"

echo "::group::Checking permissions"
OWNER=`ls -ld "$(which python)" | awk '{print $3}'`
echo "Got OWNER=$OWNER, should be $(whoami)"
test "$OWNER" == "$(whoami)"
echo "::endgroup::"

echo "::group::Checking whether Qt is working"
# LD_DEBUG=libs
python -c "from qtpy.QtWidgets import QApplication, QWidget; app = QApplication([])"
echo "::endgroup::"

echo "::group::Checking the deployed environment variables were set correctly upon environment activation"
conda env config vars list
if [[ "$MNE_MACHINE" == "macOS" && "$MACOS_ARCH" == "Intel" ]]; then
    python -c "import os; x = os.getenv('CONDA_SUBDIR'); assert x == 'osx-64', f'CONDA_SUBDIR ({repr(x)}) != osx-64'" || exit 1
fi
python -c "import os; key = 'PYTHONNOUSERSITE'; x = os.getenv(key); assert x == '1', f'{key}={repr(x)} != 1'"
python -c "import os; key = 'MAMBA_NO_BANNER'; x = os.getenv(key); assert x == '1', f'{key}={repr(x)} != 1'"
echo "::endgroup::"

if [[ "$CI_OS" == "windows-2022" ]]; then
    echo "Skipping mne sys_info (hangs sometimes!)"
else
    echo "::group::Testing mne sys_info"
    mne sys_info || exit 1
    echo "::endgroup::"
fi

echo "::group::Testing import of MNE and all additional packages included in the installer"
python -u tests/test_imports.py
echo "::endgroup::"

echo "::group::Testing GUIs"
python -u tests/test_gui.py
echo "::endgroup::"

echo "::group::Testing notebooks"
python -u tests/test_notebook.py
echo "::endgroup::"

echo "::group::Testing MNE-KIT-GUI env + package"
conda activate mne-kit-gui
python -u tests/test_mne_kit_gui.py
conda deactivate
echo "::endgroup::"

echo "::group::Testing that the JSON versions are correct"
python -u tests/test_json_versions.py
echo "::endgroup::"

echo "::group::Testing that all packages are installed that MNE-Python devs would need"
python -u tests/test_dev_installed.py
echo "::endgroup::"
