# Installers for MNE-Python

Installers for MNE-Python for macOS, Windows, and Linux.


## Installation

To install MNE-Python simply:
* double click the installer on MacOS or Windows, or
* run the shell script using `sh MNE-Python-0.23.0_installer-2021.1-Linux.sh` on *nix.

You can customize some parameters, but the default values should suit most users.
By default, a conda evironment will be installed in your home directory,
however, you can change the install location using the installer options.

You do not need to manually install Anaconda before running the installation.


## Usage

### MacOS

Open a terminal and activate the environment:

```bash
source ~/mne-python/bin/activate

# You can then use this environement with your favorite editor, for example
jupyter lab
```


## Integration with IDEs

### PyCharm

1. Open `Preferences`
2. Select `Python Interpreter`
3. Click the gear icon, and press `Add...`
4. Select `Conda Environment`, then `Existing environment` and the three dots.
5. Move to the home directory then to `mne-python/bin` and select `python`.  
   On MacOS this would be `/Users/username/mne-python/bin/python`.
7. An environment named `base` will then be available for you to use that includes MNE-Python.
