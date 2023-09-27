# Read the JSON and YAML and make sure the version + build match

import json
import os
import pathlib
import sys
import yaml

dir_ = pathlib.Path(__file__).parent.parent

sys_name = dict(
    linux="Linux",
    darwin="macOS_Intel",
    win32="Windows",
)[sys.platform]
sys_ext = dict(linux=".sh", darwin=".pkg", win32=".exe")[sys.platform]
recipe_dir = pathlib.Path(__file__).parents[1] / "recipes" / "mne-python"
construct_yaml_path = recipe_dir / "construct.yaml"
params = yaml.safe_load(construct_yaml_path.read_text(encoding="utf-8"))
installer_version = params["version"]
specs = params["specs"]
del params

# Extract versions from construct.yaml
mne_package_names = ("mne", "mne-installer-menus")  # the most important ones!
want_versions = {}

for spec in specs:
    if " " not in spec:  # only include those where we specify a version
        continue
    package_name, package_version_and_build = spec.split(" ")
    if package_name in mne_package_names:
        package_version = package_version_and_build.split("=")[1]
        package_build = (
            package_version_and_build.split("=")[-1].replace("*", "").replace("_", "")
        )
        want_versions[package_name] = {
            "version": package_version,
            "build_number": package_build,
        }

# Extract versions from created environment
fname = dir_ / f"MNE-Python-{installer_version}-{sys_name}{sys_ext}.env.json"
assert fname.is_file(), (fname, os.listdir(os.getcwd()))
env_json = json.loads(fname.read_text(encoding="utf-8"))
got_versions = dict()
for package in env_json:
    if package["name"] in mne_package_names:
        got_versions[package["name"]] = {
            "version": str(package["version"]),
            "build_number": str(package["build_number"]),
        }
assert len(got_versions) == 2, got_versions

# check versions
for package_name in mne_package_names:
    got = got_versions[package_name]
    want = want_versions[package_name]

    msg = f"{package_name}: got {repr(got)} != want {repr(want)}"
    assert got == want, msg
