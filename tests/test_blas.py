"""Check that the installed BLAS matches what construct.yaml asks for."""

import glob
import json
import pathlib
import platform
import sys

import packaging.version
import yaml

construct_yaml_path = (
    pathlib.Path(__file__).parents[1] / "recipes" / "mne-python" / "construct.yaml"
)
construct = yaml.safe_load(construct_yaml_path.read_text(encoding="utf-8"))

on_apple_silicon = sys.platform == "darwin" and platform.machine() == "arm64"
want_impl = "newaccelerate" if on_apple_silicon else "openblas"
conda_meta = pathlib.Path(sys.prefix) / "conda-meta"
print(f"Checking for a {want_impl} BLAS in {conda_meta.parent}")

# The pin post_install wrote, which governs what a later `conda install` can swap in
pinned_path = conda_meta / "pinned"
pinned = pinned_path.read_text(encoding="utf-8").splitlines()
want_pin = f"libblas=*=*{want_impl}"
assert want_pin in [line.strip() for line in pinned], (
    f"{want_pin!r} missing from {pinned_path}:\n" + "\n".join(pinned)
)
print(f"OK: {pinned_path.name} pins {want_pin}")

# The libblas that actually got solved into the installer
records = glob.glob(str(conda_meta / "libblas-*.json"))
assert len(records) == 1, f"Expected exactly one libblas record, got {records}"
libblas = json.loads(pathlib.Path(records[0]).read_text(encoding="utf-8"))
assert libblas["build"].endswith(f"_{want_impl}"), (
    f"Installed libblas {libblas['version']}={libblas['build']} is not a "
    f"{want_impl} build"
)
print(f"OK: installed libblas {libblas['version']}={libblas['build']}")

if not on_apple_silicon:
    sys.exit(0)

# Accelerate's macOS floor has moved before (13.3 -> 15.5) and constructor pre-solves,
# so virtual_specs can silently drift into letting in machines that can't run it
osx_deps = [dep for dep in libblas["depends"] if dep.startswith("__osx")]
got_floors = [
    packaging.version.parse(dep.split(">=")[1].strip())
    for dep in osx_deps
    if ">=" in dep
]
assert got_floors, f"No '__osx >=' constraint in libblas depends: {libblas['depends']}"
got_floor = max(got_floors)

osx_specs = [spec for spec in construct["virtual_specs"] if spec.startswith("__osx>=")]
assert len(osx_specs) == 1, (
    f"Expected exactly one '__osx>=' virtual_spec in {construct_yaml_path}, "
    f"got {construct['virtual_specs']}"
)
want_floor = packaging.version.parse(osx_specs[0].split(">=")[1].strip())

assert want_floor == got_floor, (
    f"libblas {libblas['build']} requires __osx >={got_floor} (from {osx_deps}), but "
    f"virtual_specs in {construct_yaml_path} pins __osx>={want_floor}. Update "
    f"virtual_specs to match, otherwise the installer will either refuse machines it "
    f"could support or accept machines that will fail at `import numpy`."
)
print(f"OK: virtual_specs __osx>={want_floor} matches the libblas requirement")
