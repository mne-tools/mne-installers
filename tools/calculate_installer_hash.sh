#!/bin/bash

set -eo pipefail

shopt -s nullglob  # Fail if the following pattern yields no results
echo "Finding matches"
matches=(MNE-Python-*-*.*)
echo "Extracting fname"
installer_fname="${matches[0]}"
echo "Found name: ${installer_fname}"
echo "Want name:  ${MNE_INSTALLER_NAME}"
test "$installer_fname" == "$MNE_INSTALLER_NAME"
hash_fname="${MNE_INSTALLER_NAME}.sha256.txt"
shasum -a 256 "$MNE_INSTALLER_NAME" > "$hash_fname"
cat "$hash_fname"
# need to raise an error if the installer is too big (it will fail to be part of any
# release)
MAX_SIZE=2147483648
actual_size=$(stat -c%s "$MNE_INSTALLER_NAME")
if [ "$actual_size" -gt "$MAX_SIZE" ]; then
    echo "Error: Installer size ($actual_size bytes) exceeds the maximum allowed size ($MAX_SIZE bytes)."
    # exit 1
fi
