import platform
import re
import subprocess
from pathlib import Path

would = "Would install "
if not Path("../mne-python").is_dir():
    print("Cloning mne-python repo...")
    subprocess.check_output(
        [
            "git",
            "clone",
            "https://github.com/mne-tools/mne-python.git",
        ],
        cwd="..",
    )
print("Running pip install dry-run to check for unmet dependencies...")
out = subprocess.check_output(
    [
        "pip",
        "install",
        "--no-build-isolation",
        "--dry-run",
        ".[full-no-qt]",
        "--group",
        "test",
        "--group",
        "test_extra",
        "--group",
        "doc",
    ],
    cwd="../mne-python",
)
out = out.decode("utf-8")
deps = [line for line in out.split("\n") if line.startswith(would)]
assert len(deps) == 1, len(deps)
deps = deps[0]
print(f"Found pip install line:\n{deps}")
deps = deps[len(would) :]
# Remove PyQt6 and some other stuff
deps = [
    dep
    for dep in deps.split()
    if not re.match("mne-[0-9]+", dep)
    and not dep.startswith("numpy-")
    and not dep.startswith("pyxdf-")
    and not dep.startswith("quantities-")
    # Qt-related stuff
    and not dep.startswith("sip-")
    and not dep.startswith("tinycss2")
    # and not on conda-forge yet
    and not dep.startswith("sphinxcontrib-towncrier")
    and not dep.startswith("toml-sort")
    and not dep.startswith("tomlkit")
    and not dep.startswith("nest-asyncio2")
    # for some reason vtk is not detected properly on Windows even though it imports
    and not (platform.system() == "Windows" and dep.startswith("vtk"))
]
deps = "\n".join(deps)
assert deps == "", f"Unexpected unmet dependencies:\n{deps}\n\nOutput:\n{out}"
