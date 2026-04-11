# Read the JSON and YAML and make sure the version + build match

import fnmatch
import json
import os
import pathlib
import platform
import sys
import yaml

dir_ = pathlib.Path(__file__).parent.parent

match sys.platform:
    case "linux":
        sys_name = "Linux"
        sys_ext = ".sh"
    case "win32":
        sys_name = "Windows"
        sys_ext = ".exe"
    case "darwin":
        sys_ext = ".pkg"
        if platform.machine() == "x86_64":
            sys_name = "macOS_Intel"
        else:
            assert platform.machine() == "arm64"
            sys_name = "macOS_M1"
    case _:
        raise ValueError(f"Platform not recognized: {sys.platform}")

recipe_dir = pathlib.Path(__file__).parents[1] / "recipes" / "mne-python"
construct_yaml_path = recipe_dir / "construct.yaml"
params = yaml.safe_load(construct_yaml_path.read_text(encoding="utf-8"))
installer_version = params["version"]
specs = params["specs"]
construct_lines = construct_yaml_path.read_text("utf-8").splitlines()
del params

# Extract versions from construct.yaml
want_versions = {}
for spec in specs:
    if not spec.count("="):
        continue
    package_name, package_version_and_build = spec.split(" ")
    spec_parts = package_version_and_build.split("=")[1:]
    package_version = spec_parts[0].rstrip("*")
    package_build = spec_parts[1] if len(spec_parts) > 1 else None
    want_versions[package_name] = {
        "version": package_version,
        "build_string": package_build,
    }
# for name in ("mne", "mne-installer-menu"):  # the most important ones!
#     assert name in want_versions, f"{name} missing from construct.yml versions"
assert len(want_versions) > 50, want_versions  # lots of packages with version specs

# Extract versions from created environment
fname = dir_ / f"MNE-Python-{installer_version}-{sys_name}{sys_ext}.env.json"
assert fname.is_file(), (fname, os.listdir(os.getcwd()))
env_json = json.loads(fname.read_text(encoding="utf-8"))
got_versions = dict()
for package in env_json:
    got_versions[package["name"]] = {
        "version": str(package["version"]),
        "build_string": str(package["build_string"]),
    }

start = construct_lines.index("  # OS-specific")
stop = construct_lines.index("  # End OS-specific defs")
ignores = [line.strip() for line in construct_lines[start:stop]]
ignores = [
    line.split("#")[0].split("=")[0][2:].strip()
    for line in ignores
    if not line.startswith("#")
]
ignores += ["numpy", "numba"]
# check versions
for package_name, want in want_versions.items():
    if package_name in ignores:
        continue
    assert package_name in got_versions, f"{package_name} missing from env.json"
    got = got_versions[package_name]
    msg = f"{package_name}: got {repr(got)} != want {repr(want)}"
    assert got["version"] == want["version"], msg
    if want["build_string"] is not None:
        assert fnmatch.fnmatch(got["build_string"], want["build_string"]), msg
