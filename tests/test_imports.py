import argparse
import importlib
from tqdm import tqdm
from pathlib import Path
import platform


parser = argparse.ArgumentParser(prog="test_imports")
parser.add_argument("--ignore", nargs="*", help="Modules to ignore", default=[])
parsed = parser.parse_args()


def _import(mod):
    try:
        return importlib.import_module(mod.replace("-", "_"))
    except Exception:
        raise ImportError(f"Could not import {repr(mod)}")


def check_version_eq(package, ver):
    """Check a minimum version."""
    from packaging.version import parse

    if isinstance(package, str):
        package = _import(package)

    try:
        package_ver = parse(package.__version__)
    except Exception:
        raise ImportError(
            f"Could not parse version for {package}: {repr(package.__version__)}"
        )
    assert package_ver >= parse(ver), (
        f"{package}: got {package.__version__} wanted {ver}"
    )


# All related software
lines = (
    (Path(__file__).parents[1] / "recipes" / "mne-python" / "construct.yaml")
    .read_text("utf-8")
    .splitlines()
)
lines = [line.strip() for line in lines]
all_lines = lines
sidx = lines.index("# <<< BEGIN RELATED SOFTWARE LIST >>>")
eidx = lines.index("# <<< END RELATED SOFTWARE LIST >>>")
lines = [line for line in lines[sidx : eidx + 1] if not line.startswith("#")]
assert lines
# NB: next line assumes that there are no "less-than" pins
mods = [line[2:].split("#")[0].split(">")[0].split("=")[0].strip() for line in lines]

# Plus some custom ones
mods += """
darkdetect qdarkstyle numba openpyxl xlrd pingouin questionary
seaborn plotly pqdm pyvistaqt vtk PySide6 PySide6.QtCore matplotlib matplotlib.pyplot
spyder spyder-kernels
""".strip().split()
if platform.system() == "Darwin":
    mods += ["Foundation"]  # pyobjc

# Now do the importing and version checking
bad_ver = {
    "mne-faster",  # https://github.com/wmvanvliet/mne-faster/pull/7
    "mne-ari",  # https://github.com/john-veillette/mne-ari/pull/7
    "pactools",  # https://github.com/pactools/pactools/pull/37
    "Foundation",
    "spyder",
    "spyder-kernels",
}
mod_map = {  # for import test, need map from conda-forge line/name to importable name
    "python-neo": "neo",
    "python-picard": "picard",
    "openneuro-py": "openneuro",
}
ver_map = {  # for __version__, need map from importable name to conda-forge line/name
    "matplotlib": "matplotlib-base",
}
ignore = list(parsed.ignore) + ["dcm2niix"]
for mod in tqdm(mods, desc="Imports", unit="module"):
    if mod in ignore:
        continue
    py_mod = _import(mod_map.get(mod, mod))
    if mod not in bad_ver and "." not in mod:
        ver_lines = [
            line
            for line in all_lines
            if line.startswith(f"- {ver_map.get(mod, mod).lower()} =")
        ]
        assert len(ver_lines) == 1, f"{mod}: {ver_lines}"
        check_version_eq(py_mod, ver_lines[0].split("=")[1])
    if mod == "matplotlib.pyplot":
        backend = py_mod.get_backend()
        assert backend.lower() == "qtagg", backend
