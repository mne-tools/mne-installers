import platform
import re
import subprocess

would = "Would install "
out = subprocess.check_output(
    [
        "pip",
        "install",
        "--no-build-isolation",
        "--dry-run",
        # This can be used to speed up local testing
        # "../mne-python[full,test,test_extra,doc]",
        "mne[full-no-qt,test,test_extra,doc] @ git+https://github.com/mne-tools/mne-python.git@main",
    ]
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
    # TODO because we don't install neo
    and not dep.startswith("neo-")
    and not dep.startswith("numpy-")
    and not dep.startswith("pyxdf-")
    and not dep.startswith("quantities-")
    # Qt-related stuff
    and not dep.startswith("sip-")
    # and not on conda-forge yet
    and not dep.startswith("sphinxcontrib-towncrier")
    and not dep.startswith("antio")
    and not dep.startswith("toml-sort")
    and not dep.startswith("tomlkit")
    and not dep == "pyarrow-15.0.0"  # not tensorflow compatible
    # for some reason vtk is not detected properly on Windows even though it imports
    and not (platform.system() == "Windows" and dep.startswith("vtk"))
]
deps = "\n".join(deps)
assert deps == "", f"Unexpected unmet dependencies:\n{deps}"
