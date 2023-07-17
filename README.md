# Installers for MNE-Python

Installers for MNE-Python for macOS, Windows, and Linux.

<img src="https://mne.tools/dev/_static/mne_installer_macOS.png" alt="Installer running on macOS" width="450px">

Please visit [the installers section of the MNE documentation](https://mne.tools/dev/install/installers.html) for instructions on how to use them.

## Development

Locally, installers can be built using `tools/build_local.sh`. Steps:

1. Set up and activate a `conda` env with a forked version of `constructor`:
   ```console
   $ conda env create -f environment.yml
   $ conda activate constructor-env
   ```
2. If you want to build an arm64 (M1) package on a macOS Intel machine, run `source ./tools/setup_m1_crosscompile.sh`.
3. Run `./tools/build_local.sh`.
4. Install the environment for your platform.
5. Test it using the `tests/`.
