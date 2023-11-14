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
        "mne[full,test,test_extra,doc] @ git+https://github.com/mne-tools/mne-python.git@main",
    ]
)
out = out.decode("utf-8")
deps = [line for line in out.split("\n") if line.startswith(would)]
assert len(deps) == 1, len(deps)
deps = deps[0]
print(f"Found pip install line:\n{deps}")
deps = deps[len(would) :]
deps = "\n".join(dep for dep in deps.split() if not re.match("mne-[0-9]+", dep))
assert deps == "", f"Unexpected unmet dependencies:\n{deps}"
