import os
from pathlib import Path

menu_path = Path(os.environ["PREFIX"]) / "Menu"
print(f"Looking for paths in {menu_path} ...")
assert menu_path.parent.is_dir(), f"Not a directory: {menu_path.parent=}"
options = "\n".join(sorted(os.listdir(menu_path.parent)))
assert menu_path.is_dir(), f"Not a directory: {menu_path=}\n{options}"
for name in (
    "mne.json",
    "mne_default_icon.png",
    "mne.png",
    "mne_sys_info.py",
    "mne_open_prompt.applescript",
    "mne_open_prompt.sh",
    "mne_open_prompt.bat",
    "mne_activate.bat",
):
    want_path = menu_path / name
    assert want_path.is_file(), f"Could not find {want_path}"

# Check we didn't forget any icons
for ext in ("icns", "ico", "png"):
    for fstem in ("console", "info", "web", "forum"):
        fpath = menu_path / f"mne_{fstem}.{ext}"
        assert fpath.is_file(), f"Could not find {fpath}"
print("Done!")
