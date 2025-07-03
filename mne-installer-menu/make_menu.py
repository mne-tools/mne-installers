#!/usr/bin/env python3
"""Replace some markers in the JSON and other files; copy and rename others.

Note that there are various {{ VAR }} Jinja template markers left in the JSON file,
but these are for processing by ``menuinst`` - see:
https://github.com/conda/menuinst/blob/1866363f197e0633fae0db8569119d102ca8d9cc/menuinst/platforms/base.py#L80
"""

# Adapted heavily from https://github.com/scientific-python/installer

from os import environ
from pathlib import Path
from shutil import copy2

# https://docs.conda.io/projects/conda-build/en/latest/user-guide/environment-variables.html
in_path = Path(environ["RECIPE_DIR"]) / "menu"
prefix = environ["PREFIX"]
out_path = Path(prefix) / "Menu"
pkg_version = environ["PKG_VERSION"]

out_path.mkdir(parents=True, exist_ok=True)


def txt_replace(txt):
    """Apply our own markup for search / replace.

    We use ``#MY_VAR#`` as indication to insert static text.
    """
    for start, end in (
        ("#PREFIX#", prefix),
        ("#PKG_VERSION#", pkg_version),
    ):
        txt = txt.replace(start, end)
    return txt


menu_txt = (in_path / "menu.json").read_text()
(out_path / "mne.json").write_text(txt_replace(menu_txt))


# icons, with mne_ prefix
for ext in ("icns", "ico", "png"):
    for fstem in ("console", "info", "web", "forum"):
        fpath = in_path / f"{fstem}.{ext}"
        copy2(fpath, out_path / f"mne_{fpath.name}")

# shell scripts, with mne_ prefix
for ext in ("sh", "applescript", "bat"):
    for fstem in ("open_prompt",):
        fpath = in_path / f"{fstem}.{ext}"
        text = txt_replace(fpath.read_text())
        (out_path / out_path / f"mne_{fpath.name}").write_text(text)

# other, with same filenames
for fname in ("mne_sys_info.py", "mne.png", "mne_default_icon.png"):
    fpath = in_path / fname
    copy2(fpath, out_path / fpath.name)
