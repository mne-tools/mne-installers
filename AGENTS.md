# AGENTS.md

This file provides guidance to AI coding agents when working with this repository.

## What this is

`mne-installers` builds the standalone MNE-Python installers for macOS, Windows, and
Linux using [`constructor`](https://github.com/conda/constructor). There is almost no
Python "library" code here: the repository is a `constructor` recipe
(`recipes/mne-python/construct.yaml`), the installer assets, shell scripts that drive
the build, a small `rattler-build` package for menu shortcuts (`mne-installer-menu/`),
and tests that run inside a freshly installed environment on CI.

## AI-assistance policy (read first)

This repository follows the MNE-Python AI usage policy:

https://github.com/mne-tools/mne-python/blob/main/CONTRIBUTING.md#policy-on-ai-assistance-in-contributions

In short: contributing requires human judgment and understanding, and every issue, pull
request, review, and comment is an interaction between people. Concretely:

- **A human opens and owns every issue and PR.** Fully automated submissions are not
  accepted. The human contributor must have personally reviewed, understood, and tested
  every change and must be able to explain and defend it on request.
- **No AI-generated text in issues, PRs, or comments.** Do not draft issue reports, PR
  descriptions, review replies, or discussion comments for the human to paste. If you
  are asked to summarize your work, give the human the facts and let them write it in
  their own words.
- **Disclose AI assistance in the PR description.** The human states which tools were
  used and the manner and scope of their assistance.
- **Do not add AI co-authorship trailers to commits.** No `Co-Authored-By:` line for
  Claude, Copilot, Cursor, or any other tool, and no bot as the commit author. The human
  is the sole author; disclosure belongs in the PR description, not in git metadata.
- **Do not open, comment on, label, approve, or merge anything on GitHub yourself.**
  Do not push to `main` or to shared branches. Local work is fine; anything visible to
  other people goes through the human.
- **Optimize for the reviewer and for long-term maintainability, not for output volume.**
  Every line you add is read by a volunteer reviewer and then maintained by humans in
  perpetuity, usually by someone other than the person who merged it. See "Keep changes
  small" below; oversized diffs are the single most common problem with agent-assisted
  PRs.

Maintainers may close PRs that appear to violate this policy without review.

## Keep changes small

A big diff is a cost, not an accomplishment. Aim for the smallest change that delivers
the user-visible behavior; anything else can be added later, when something actually
needs it.

- **Sketch before you generate.** For anything beyond a one-line pin change, summarize
  the design in a few sentences for the human you are working with and confirm it is
  the smallest thing that works before writing code. The human decides whether and how
  to raise it publicly, in their own words.
- **Stop and re-plan at roughly 100 new lines.** Growth past that, or reaching for a new
  script in `tools/`, a new file in `tests/`, a new workflow, or a new package in the
  installer, is a signal that the design is too elaborate, not that progress is being
  made. Stop, tell the human, and offer the smaller version.
- **YAGNI.** No retry loops, fallbacks for platforms we do not build, configuration
  knobs, environment-variable switches, or "robustness" that no current build needs.
  Shell scripts here are deliberately plain: `set -e`-style scripts that do one thing
  and fail loudly. Hard-code the single behavior that is wanted.
- **DRY: reuse before writing.** `tools/extract_version.sh` already derives the version,
  installer name, prefix, and activation script; `check_installation.sh` already has the
  per-OS branching; `test_outdated.py` already parses `construct.yaml`. Build on these
  rather than re-deriving the same values in a second place, and if two scripts need the
  same logic, factor it into one helper rather than copying it.
- **Never add a package to the installer as a side effect.** A new entry in `specs` is
  user-visible, adds to the 2 GB budget, and has to be kept solvable on three platforms
  forever. Adding one, or adding a build-time tool to `environment.yml`, needs a
  demonstrated need and an explicit request from the human.
- **Workarounds must say when they can go.** A pin held back with `# allow_outdated`, a
  commented-out channel, or a hack in a post-install script must carry a comment naming
  the reason and the condition for removal, with the upstream issue or PR when there is
  one (see the existing `# TODO:` comments in `construct.yaml` for the style). These are
  grepped for when updating, so an unmarked workaround tends to outlive its reason.

## Tests

Tests in this repository are expensive: each PR builds full installers on macOS, Windows,
and Linux and runs the whole `tests/` directory inside each one, so CI time is measured
in hours and every added check runs several times per PR.

- **Keep tests compact and add to existing ones.** In order of preference: add an
  assertion to the existing test script that already covers the area (`test_imports.py`
  for "does package X import", `test_json_versions.py` for pin consistency,
  `test_blas.py` for BLAS, `check_installation.sh` for filesystem or shortcut checks),
  then a small new function in an existing file, and only then a new file. A new file in
  `tests/` is a signal to stop and look.
- **A few assertions that run on every platform beat a long script that runs once.**
  Minimize both runtime (for CI) and verbosity (for reviewers).
- **Do not add tests that need network access, large downloads, or a display** beyond
  what the existing tests already require; the CI runners are the only place these run.
- **Test the installer, not the tools.** These tests verify what a user gets after
  installing; they are not unit tests for the build scripts, and a change that only
  touches `tools/` usually needs no new test, just a green CI build.

## Code conventions

- Python in `tests/` follows the MNE-Python conventions: `snake_case`, no abbreviated
  names, no nested functions, numpydoc docstrings where a docstring is warranted. `ruff`
  and `yamllint` run via pre-commit and enforce the rest.
- Shell scripts use `bash` with `-e` (most start with `#!/bin/bash -ef` or
  `set -eo pipefail`) and GitHub Actions `::group::` markers for long output.
- Code adapted from an outside source (NSIS snippets, post-install tricks, Stack Overflow
  answers) must be under a BSD-compatible license (BSD, MIT, ISC, Apache-2.0, public
  domain); GPL/LGPL/AGPL and non-commercial or no-derivatives licenses are not
  acceptable. Attribute it in a comment directly above the adapted code naming the
  source URL and license. If the license cannot be determined, do not adapt it.
- There is no changelog to edit. Release notes are generated from PR titles by
  `.github/release.yaml`, so the PR title should describe the user-visible effect
  (e.g. "Add pymef", "Switch to accelerate on arm64"), not the mechanics.

## Layout

- `recipes/mne-python/construct.yaml` — the `constructor` recipe. This is the file
  almost every change touches: version, install prefixes, channels, and the `specs` list
  of pinned packages. It uses `constructor` selectors (`# [osx]`, `# [win]`, etc.) at
  the end of lines. Several comment lines are markers that other tooling parses
  (`<<< BEGIN/END RELATED SOFTWARE LIST >>>` is read by MNE-Python's docs; the
  OS-specific block markers are read by `tests/test_json_versions.py`). Do not edit
  or move those marker lines.
- `assets/` — welcome/conclusion/license text, images, and the per-OS `post_install`
  scripts that run at the end of installation.
- `mne-installer-menu/` — a `rattler-build` recipe providing the Start Menu / Dock /
  `.desktop` shortcuts. Built into `conda-bld/` by `tools/run_local_build.sh`, which
  `construct.yaml` consumes via the `./conda-bld` channel.
- `tools/` — shell scripts used by CI and for local builds. `extract_version.sh` derives
  the version, installer filename, and install prefix from `construct.yaml`;
  `check_installation.sh` runs the post-install checks and tests on CI.
- `tests/` — scripts that run *inside the installed environment* on CI (imports, Qt,
  BLAS, notebooks, GUIs), plus `test_outdated.py`, which runs in a plain environment
  and compares pins in `construct.yaml` against conda-forge.
- `.github/workflows/` — `build.yml` builds and tests all installers on every PR and
  push, and creates a GitHub prerelease on tag pushes; `update_deps.yml` runs
  `test_outdated.py` weekly and opens a bot PR; `automerge.yml` merges bot PRs when
  green.

## Common tasks

Dependency pins live in the `specs` list in `construct.yaml`. Conventions:

- Every package is pinned to an exact version. The weekly `update_deps.yml` job bumps
  them automatically via `tests/test_outdated.py`.
- To hold a package back on purpose, append `# allow_outdated` (with a reason) to its
  line so the updater skips it. Roll back a single pin this way rather than reverting a
  whole update PR.
- The `# TODO: ⛔️ ... DEV BUILDS ...` blocks are toggled during the MNE-Python release
  cycle to build against `conda-forge/label/mne_dev`; leave them alone otherwise.
- Installers must stay under 2 GB (GitHub release asset limit). Adding a package with
  many transitive dependencies (e.g. anything pulling in R or a second Qt binding) is
  not acceptable. `check_installation.sh` fails the build when the size is exceeded.
- Spyder is installed as `spyder-base`, not `spyder`, so that the Qt binding stays
  PySide6 rather than PyQt5. `check_installation.sh` asserts `qtpy.API_NAME == 'PySide6'`.

Bumping the installer version (a new MNE-Python release) means changing the `version:`
line **and** every hard-coded `1.X.Y_0` occurrence in `construct.yaml` (default
prefixes, `installer_filename`, `env_prompt`), as the comment at the top of the file
notes. Check with `grep -n "1\.13\.2" recipes/mne-python/construct.yaml` (substituting
the old version).

## Building and testing locally

```bash
conda env create -f environment.yml
conda activate constructor-env
./tools/build_local.sh           # builds mne-installer-menu, then runs constructor
./tools/build_local.sh --dry-run # solves the env, skips downloading and packaging
```

`build_local.sh` just runs two scripts, which can also be run separately:

```bash
./tools/run_local_build.sh           # builds mne-installer-menu into conda-bld/
./tools/run_constructor.sh --dry-run # solves the specs for the current platform only
```

After editing `specs`, the dry-run solve is the fastest way to catch unsolvable pins
(a few minutes, versus the full CI build). The menu package only needs rebuilding when
`mne-installer-menu/` or the installer version changes.

`constructor` cannot solve for another OS, so `./tools/run_constructor.sh --platform
osx-arm64` (or `osx-64`, `win-64`, `linux-64`) instead runs `conda create --dry-run` on
that platform's specs with faked virtual packages. This is only an approximation for
debugging conflicts on OSes you do not have; CI is the source of truth.

Full installer builds take a long time and need the platform they target, so most
recipe changes are validated by opening a PR and letting CI build all platforms. For a
quick local check of the `specs` list against conda-forge:

```bash
python tests/test_outdated.py    # exits 1 if anything is outdated; read the diff
```

Lint and format (ruff, yamllint) run via pre-commit:

```bash
pre-commit run -a
```

The scripts in `tests/` other than `test_outdated.py` expect to be run from inside an
installed MNE-Python environment (see `tools/check_installation.sh`), not from the
`constructor-env`.
