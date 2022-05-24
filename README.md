# Installers for MNE-Python

Installers for MNE-Python for macOS, Windows, and Linux.

<img src="https://mne.tools/dev/_static/mne_installer_macOS.png" alt="Installer running on macOS" width="450px">

Please visit [the installers section of the MNE documentation](https://mne.tools/dev/install/installers.html) for instructions on how to use them.

## Development

Locally, installers can be built using `tools/build_local.sh`. This has only been tested on Linux and macOS M1.

Requirements:

1. Set up and activate a `conda` env with a patched, forked version of `constructor`:
  ```console
  $ conda env create -f environment.yml
  $ conda activate constructor-env
  $ ./tools/patch_constructor.sh
  ```
2. Run `./tools/build_local.sh`
3. Install the environment for your platform
4. Test it using the `tests/`
