# Read the JSON and YAML and make sure the version + build match

import os
import sys
from pathlib import Path
import json
import yaml

dir_ = Path(__file__).parent.parent

sys_name = dict(
    linux='Linux',
    darwin='macOS',
    win32='Windows',
)[sys.platform]

with open(dir_ / 'recipes' / 'mne-python_1.0' / 'construct.yaml') as fid:
    params = yaml.safe_load(fid)
want_version = params['version']

fname = dir_ / f'MNE-Python-{want_version}-{sys_name}.env.json'
assert fname.is_file(), (fname, os.listdir(os.getcwd()))
with open(fname) as fid:
    env_json = json.load(fid)
got_versions = dict()
for package in env_json:
    if package['name'] in ('mne', 'mne-installer-menus'):
        v, b = package['version'], package['build_number']
        got_versions[package['name']] = f'{v}_{b}'
assert len(got_versions) == 2, got_versions

# sanitize versions
for name, version in got_versions.items():
    msg = f'{name}: got {repr(version)} != want {repr(want_version)}'
    assert version == want_version, msg
