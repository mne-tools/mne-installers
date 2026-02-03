"""Look for outdated packages and suggest updates."""

# %%
import re
import sys
import time
from dataclasses import dataclass
from pathlib import Path

import packaging.version
import requests
import yaml
import tomllib

try:
    from joblib import Memory, expires_after
except ImportError:

    def _cache(fun):
        return fun
else:
    memory = Memory(Path(__file__).parent / ".joblib_cache", verbose=0)
    _cache = memory.cache(cache_validation_callback=expires_after(minutes=60))

recipe_dir = Path(__file__).parents[1] / "recipes" / "mne-python"
construct_yaml_path = recipe_dir / "construct.yaml"
print(f"Analyzing spec file: {construct_yaml_path}\n")

recipe = construct_yaml_path.read_text(encoding="utf-8")
lines = [line.strip() for line in recipe.splitlines()]
lines = [
    line
    for line in lines[lines.index("specs:") + 1 : lines.index("extra_envs:")]
    if line and not line.startswith("#")
]
for line in lines:
    assert line.startswith("- "), f"Line does not start with '- ': {line=}"
lines = [line[2:] for line in lines]
specs = yaml.safe_load(recipe)["specs"]
assert len(specs) == len(lines), f"{len(specs)=} != {len(lines)=}"
LJUST = 25


@dataclass()
class Package:  # noqa: D101
    name: str
    version_spec: str | None
    version_conda_forge: str | None = None


allowed_outdated: set[str] = set()
packages: list[Package] = []

for line, spec in zip(lines, specs):
    if "#" in line:
        line_spec, comment = line.split("#", maxsplit=1)
        line_spec = line_spec.strip()
    else:
        line_spec, comment = line, ""
    assert line_spec == spec, f"{line_spec=} != {spec=}"
    del line_spec

    if " " in spec:
        assert spec.count(" ") == 1, f"Wrong number of spaces in spec: {spec}"
        name, version = spec.split(" ")
        version = (version.lstrip("~").lstrip("=").split("="))[0]  # build number
        if version == "!":  # this is "a !=something", we can skip it
            version = None
        elif version.startswith(("<", ">")):  # "a <something" or ">=something"
            version = None
    else:
        name = spec
        version = None

    if "allow_outdated" in comment:
        allowed_outdated.add(name)
    if "locally_built" in comment:
        # This is a locally built package, we can skip it
        print(f"Skipping locally built package: {name}")
        continue

    packages.append(Package(name=name, version_spec=version))
    del name, version


@_cache
def get_github_file(filename, *, repo="mne-tools/mne-python"):
    """Get conda json for a package."""
    url = f"https://github.com/{repo}/raw/refs/heads/main/{filename}"
    return requests.get(url).text


@_cache
def get_conda_json(package):
    """Get conda json for a package."""
    anaconda_url = f"https://api.anaconda.org/package/conda-forge/{package.name}"
    for _ in range(5):  # retries
        r = requests.get(anaconda_url)
        if r.status_code == 404:
            print(f"{package.name} not found on conda-forge")
            not_found.append(package)
            continue

        try:
            json = r.json()
        except requests.exceptions.JSONDecodeError:
            time.sleep(0.1)
        else:
            break
    else:
        raise RuntimeError(f"{package.name} failed to get JSON from conda-forge")
    return json


# Check to make sure we have all packages we need
mne_toml = tomllib.loads(get_github_file("pyproject.toml"))
mne_deps = (
    mne_toml["project"]["dependencies"]
    + mne_toml["project"]["optional-dependencies"]["full-no-qt"]
    + mne_toml["dependency-groups"]["doc"]
    + mne_toml["dependency-groups"]["test"]
)
mne_deps += [
    dep for dep in mne_toml["dependency-groups"]["test_extra"] if isinstance(dep, str)
]  # remove dict entries (like {"include-group": "test"})
mne_dep_names = [re.split(r"[;<>=! ]", dep)[0].replace("_", "-") for dep in mne_deps]
# Fix a few
pypi_to_conda = {
    "mne[hdf5]": "mne",
    "matplotlib": "matplotlib-base",
    "neo": "python-neo",
    "jupyter-client": "jupyter_client",
    "memory-profiler": "memory_profiler",
}
mne_dep_names = [pypi_to_conda.get(name, name) for name in mne_dep_names]
# remove a few exceptions (toml-sort not on conda-forge, don't need others)
for name in "sip tomli toml-sort nest-asyncio2".split():
    mne_dep_names.pop(mne_dep_names.index(name))
# add conda-forge ones
meta_str = get_github_file("recipe/meta.yaml", repo="conda-forge/mne-feedstock")
# remove jinja lines and expressions
meta_str = re.sub("({%.+?%})", "", meta_str)
meta_str = re.sub(r"({{.+?}})", "placeholder", meta_str)
mne_feedstock = yaml.safe_load(meta_str)
mne_output = mne_feedstock["outputs"][1]
assert mne_output["name"] == "mne", f"Need mne, got {mne_output['name']=}"
feedstock_dep_names = sorted(
    re.split(r"[;<>=! ]", dep)[0] for dep in mne_output["requirements"]["run"]
)
for dep in "placeholder __osx pyqt pyobjc-framework-cocoa".split():
    feedstock_dep_names.pop(feedstock_dep_names.index(dep))
missing = sorted(
    set(mne_dep_names).union(set(feedstock_dep_names))
    - set(pkg.name for pkg in packages)
)

outdated = []
not_found = []
for package in packages:
    if package.version_spec is None:
        continue

    try:
        json = get_conda_json(package)
    except RuntimeError as exc:
        print(str(exc))
        not_found.append(package)
        continue

    # Iterate in reverse chronological order, omitting versions marked as broken and
    # those that are not in the main channel
    # TODO We may want to make exceptions here for MNE testing versions if we need them
    version = None
    for file in json["files"][::-1]:
        if "broken" in file["labels"]:
            continue
        elif "main" not in file["labels"]:
            continue
        elif ".rc" in file["version"]:
            continue
        else:
            version = file["version"]
            break

    assert version is not None

    package.version_conda_forge = version
    del json, version

    comp = {}
    this_version = packaging.version.parse(package.version_spec)
    if (
        this_version < packaging.version.parse(package.version_conda_forge)
        and package.version_conda_forge
        and not re.match(".*[0-9.]rc[0-9].*", package.version_conda_forge)
    ):
        mismatch = f"{package.version_spec} < {package.version_conda_forge}"
        if package.name in allowed_outdated:
            print(f"  {package.name.ljust(LJUST)} ✓ allowed  {mismatch}")
        else:
            print(f"* {package.name.ljust(LJUST)} ✗ OUTDATED {mismatch}")
            outdated.append(package)
    else:
        print(f"  {package.name.ljust(LJUST)} ✓")

exit_code = 0
if not_found:
    print(f"\n{len(not_found)} packages not found on conda-forge:\n")
    print("\n".join(f" * {package.name}" for package in not_found))
    exit_code = 1

if missing:
    print(f"\n{len(missing)} packages from MNE pyproject.toml missing from recipe:\n")
    print("\n".join(f" * {name}" for name in missing))
    print("\nPlease add to the construct.yaml recipe in the correct section(s).")
    exit_code = 1

if outdated:
    print(f"\n{len(outdated)} packages outdated:\n")
    print(
        "\n".join(
            [
                f" * {package.name} "
                f"({package.version_spec} < {package.version_conda_forge})"
                for package in outdated
            ]
        )
    )
    exit_code = 1
else:
    print("\nEverything is up to date.")

if __name__ == "__main__":
    if exit_code == 1:  # stuff needs updating
        print("Updating .yaml file.")
        orig_recipe = recipe  # keep a copy for comparison in testing
        for package in outdated:
            use_spec = package.version_spec.replace(".", r"\.")
            recipe = re.sub(
                # Three groups: 1: package name, 2: version spec, 3: rest of line
                f"^( +- {package.name} =)({use_spec})(.*)$",
                # Put back the first and third group, replace the second
                rf"\g<1>{package.version_conda_forge}\g<3>",
                recipe,
                flags=re.MULTILINE,
            )
        construct_yaml_path.write_text(recipe, encoding="utf-8")

    sys.exit(exit_code)
