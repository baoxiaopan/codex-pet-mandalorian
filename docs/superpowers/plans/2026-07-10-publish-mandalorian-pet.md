# Publish Mandalorian Codex Pet Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish the verified Mandalorian Codex v2 pet, curated public QA evidence, installer, and complete usage documentation directly to the repository's `main` branch.

**Architecture:** The repository root is the installable pet package, so users can copy `pet.json` and `spritesheet.webp` without navigating a build system. `scripts/install.sh` performs a guarded two-file installation into `${CODEX_HOME:-$HOME/.codex}`, while `assets/` and `qa/` provide human-readable previews and sanitized validation evidence without exposing generation internals.

**Tech Stack:** POSIX-oriented Bash, Git, jq, WebP/PNG assets, JSON metadata, Markdown.

## Global Constraints

- The published pet id is exactly `mandalorian` and `spriteVersionNumber` is exactly `2`.
- The published atlas is RGBA WebP, `1536×2288`, arranged as 8 columns and 11 rows.
- Publish only the package, README, installer, curated previews, curated QA evidence, design record, and this plan.
- Exclude prompts, blind-test answer keys, temporary rows, decoded frames, and production intermediates.
- The installer must not delete unrelated files or modify global Codex configuration.
- Publish directly to `origin/main`; never force-push or rewrite history.
- The character remains an original armored fox-cat guardian and must not be presented as a protected franchise character.

---

### Task 1: Add the Verified Pet Package and Curated QA

**Files:**
- Create: `pet.json`
- Create: `spritesheet.webp`
- Create: `assets/contact-sheet.png`
- Create: `assets/look-directions.png`
- Create: `qa/validation.json`
- Create: `qa/chroma-despill.json`
- Create: `qa/direction-semantics.json`
- Create: `qa/final-visual-qa.json`

**Interfaces:**
- Consumes: verified artifacts from `/Users/baoxiaopan/.codex/pets/mandalorian` and `/Users/baoxiaopan/workspace/dailywork/output/hatch-pet/mandalorian`
- Produces: a self-contained root pet package and public QA files consumed by the installer and README

- [ ] **Step 1: Verify the source package before copying**

Run:

```bash
jq -e '.id == "mandalorian" and .spriteVersionNumber == 2 and .spritesheetPath == "spritesheet.webp"' \
  /Users/baoxiaopan/.codex/pets/mandalorian/pet.json
shasum -a 256 \
  /Users/baoxiaopan/.codex/pets/mandalorian/spritesheet.webp \
  /Users/baoxiaopan/workspace/dailywork/output/hatch-pet/mandalorian/final/spritesheet-extended.webp
```

Expected: jq prints `true`; both SHA-256 values are identical.

- [ ] **Step 2: Copy the package and preview assets**

Run:

```bash
mkdir -p assets qa
cp /Users/baoxiaopan/.codex/pets/mandalorian/pet.json pet.json
cp /Users/baoxiaopan/.codex/pets/mandalorian/spritesheet.webp spritesheet.webp
cp /Users/baoxiaopan/workspace/dailywork/output/hatch-pet/mandalorian/qa/contact-sheet-extended.png assets/contact-sheet.png
cp /Users/baoxiaopan/workspace/dailywork/output/hatch-pet/mandalorian/qa/look-directions.png assets/look-directions.png
```

Expected: all four destination files exist.

- [ ] **Step 3: Create sanitized public QA files**

Run:

```bash
jq '.file = "spritesheet.webp"' \
  /Users/baoxiaopan/workspace/dailywork/output/hatch-pet/mandalorian/final/validation-extended.json \
  > qa/validation.json
jq '.input = "spritesheet.webp" | .output = "spritesheet.webp"' \
  /Users/baoxiaopan/workspace/dailywork/output/hatch-pet/mandalorian/qa/chroma-despill-extended.json \
  > qa/chroma-despill.json
cp /Users/baoxiaopan/workspace/dailywork/output/hatch-pet/mandalorian/qa/direction-semantics.json qa/direction-semantics.json
cp /Users/baoxiaopan/workspace/dailywork/output/hatch-pet/mandalorian/qa/final-visual-qa.json qa/final-visual-qa.json
```

Expected: the files contain no `/Users/baoxiaopan` path and retain their successful verdicts.

- [ ] **Step 4: Validate the copied package and curated QA**

Run:

```bash
shasum -a 256 spritesheet.webp /Users/baoxiaopan/.codex/pets/mandalorian/spritesheet.webp
jq -e '.ok == true and .width == 1536 and .height == 2288 and .rows == 11 and .columns == 8' qa/validation.json
jq -e '.ok == true and .alpha_preserved == true' qa/chroma-despill.json
jq -e '.ok == true and (.directions | length == 16) and ([.directions[].verdict] | all(. != "fail"))' qa/direction-semantics.json
jq -e '.visual_qa == "pass"' qa/final-visual-qa.json
! rg -n '/Users/baoxiaopan|direction-blind-answer-key|prompts/' pet.json qa assets
```

Expected: hashes match; every jq command prints `true`; the privacy scan returns no matches.

- [ ] **Step 5: Commit the verified package**

```bash
git add pet.json spritesheet.webp assets qa
git commit -m "add verified Mandalorian pet package"
```

Expected: one commit containing only package and curated QA artifacts.

---

### Task 2: Add and Test the Installer

**Files:**
- Create: `scripts/install.sh`

**Interfaces:**
- Consumes: repository-root `pet.json` and `spritesheet.webp`
- Produces: an executable command that installs both files into `${CODEX_HOME:-$HOME/.codex}/pets/mandalorian`

- [ ] **Step 1: Confirm the installer does not already exist**

Run:

```bash
test ! -e scripts/install.sh
```

Expected: exit code 0.

- [ ] **Step 2: Create the guarded installer**

Create `scripts/install.sh` with exactly:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PET_JSON="$REPO_ROOT/pet.json"
SPRITESHEET="$REPO_ROOT/spritesheet.webp"
CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"
PET_DIR="$CODEX_ROOT/pets/mandalorian"

if [[ ! -f "$PET_JSON" ]]; then
  echo "Missing required file: $PET_JSON" >&2
  exit 1
fi

if [[ ! -f "$SPRITESHEET" ]]; then
  echo "Missing required file: $SPRITESHEET" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required to validate pet.json." >&2
  exit 1
fi

if ! jq -e '.id == "mandalorian" and .spriteVersionNumber == 2 and .spritesheetPath == "spritesheet.webp"' "$PET_JSON" >/dev/null; then
  echo "pet.json is not a valid Mandalorian v2 pet manifest." >&2
  exit 1
fi

mkdir -p "$PET_DIR"
cp "$PET_JSON" "$PET_DIR/pet.json"
cp "$SPRITESHEET" "$PET_DIR/spritesheet.webp"

echo "Installed Mandalorian to $PET_DIR"
```

- [ ] **Step 3: Make the installer executable and validate its syntax**

Run:

```bash
chmod +x scripts/install.sh
bash -n scripts/install.sh
```

Expected: exit code 0 and no output.

- [ ] **Step 4: Test installation in an isolated Codex home**

Run:

```bash
TEST_CODEX_HOME="$(mktemp -d)"
CODEX_HOME="$TEST_CODEX_HOME" ./scripts/install.sh
jq -e '.id == "mandalorian" and .spriteVersionNumber == 2' "$TEST_CODEX_HOME/pets/mandalorian/pet.json"
shasum -a 256 spritesheet.webp "$TEST_CODEX_HOME/pets/mandalorian/spritesheet.webp"
```

Expected: installer reports the isolated path; jq prints `true`; hashes match.

- [ ] **Step 5: Commit the installer**

```bash
git add scripts/install.sh
git commit -m "add guarded Codex pet installer"
```

Expected: one commit containing the executable installer.

---

### Task 3: Replace the README with Complete User Documentation

**Files:**
- Modify: `README.md`

**Interfaces:**
- Consumes: the root package, `scripts/install.sh`, curated previews, curated QA, and the approved repository design
- Produces: the public entry point for discovery, installation, validation, updates, uninstalling, and IP boundaries

- [ ] **Step 1: Replace README.md with the final documentation**

Create `README.md` with exactly:

````markdown
# Mandalorian — Codex Pet

Mandalorian is an original armored fox-cat companion for Codex: calm, loyal, tactical, and mildly deadpan. It treats bugs, flaky tests, and messy diffs like trails to track—while keeping the final change surgical.

This repository contains a complete Codex v2 pet package with nine standard animation states and sixteen clockwise look directions.

![Mandalorian animation contact sheet](assets/contact-sheet.png)

## Highlights

- Original non-human armored code guardian
- Premium 3D game-companion style
- Nine standard Codex animation rows
- Sixteen look directions with verified cardinal semantics
- Transparent `1536×2288` WebP atlas
- Codex pet manifest with `spriteVersionNumber: 2`
- Guarded one-command installer

## Install

Clone the repository and run the installer:

```bash
git clone git@github.com:baoxiaopan/codex-pet-mandalorian.git
cd codex-pet-mandalorian
./scripts/install.sh
```

The installer copies the package to:

```text
${CODEX_HOME:-$HOME/.codex}/pets/mandalorian/
├── pet.json
└── spritesheet.webp
```

`jq` is required for manifest validation.

## Manual Installation

```bash
PET_DIR="${CODEX_HOME:-$HOME/.codex}/pets/mandalorian"
mkdir -p "$PET_DIR"
cp pet.json spritesheet.webp "$PET_DIR/"
```

Both files must be installed together. The `spriteVersionNumber: 2` field is required for the 11-row atlas contract.

## Update

```bash
git pull --ff-only
./scripts/install.sh
```

## Verify

Confirm the manifest:

```bash
jq '{id, displayName, spriteVersionNumber, spritesheetPath}' pet.json
```

Expected values:

```json
{
  "id": "mandalorian",
  "displayName": "Mandalorian",
  "spriteVersionNumber": 2,
  "spritesheetPath": "spritesheet.webp"
}
```

The curated QA records are available under [`qa/`](qa/):

- [`validation.json`](qa/validation.json): atlas dimensions, grid, alpha, and v2 validation
- [`chroma-despill.json`](qa/chroma-despill.json): edge-local chroma cleanup result
- [`direction-semantics.json`](qa/direction-semantics.json): all sixteen labeled direction verdicts
- [`final-visual-qa.json`](qa/final-visual-qa.json): final identity, animation, and continuity review

![Mandalorian look directions](assets/look-directions.png)

## Uninstall

Remove only this pet directory:

```bash
rm -r "${CODEX_HOME:-$HOME/.codex}/pets/mandalorian"
```

## Repository Layout

```text
.
├── README.md
├── pet.json
├── spritesheet.webp
├── assets/
│   ├── contact-sheet.png
│   └── look-directions.png
├── qa/
│   ├── validation.json
│   ├── chroma-despill.json
│   ├── direction-semantics.json
│   └── final-visual-qa.json
├── scripts/
│   └── install.sh
└── docs/superpowers/
    ├── plans/
    └── specs/
```

## Character and IP Boundary

Mandalorian is an original fox-cat mascot inspired only by broad armored-guardian and space-western themes. It does not depict or copy a known franchise protagonist, protected helmet or armor design, insignia, named lore, companion character, weapon, or catchphrase.

The name identifies this custom Codex pet. No affiliation with or endorsement by any entertainment franchise is claimed.
````

- [ ] **Step 2: Validate README links and commands**

Run:

```bash
for path in \
  assets/contact-sheet.png \
  assets/look-directions.png \
  qa/validation.json \
  qa/chroma-despill.json \
  qa/direction-semantics.json \
  qa/final-visual-qa.json \
  scripts/install.sh; do
  test -e "$path"
done
rg -n 'Install|Manual Installation|Update|Verify|Uninstall|Repository Layout|IP Boundary' README.md
```

Expected: every path exists and each required README section is found.

- [ ] **Step 3: Commit the README**

```bash
git add README.md
git commit -m "document Mandalorian installation and validation"
```

Expected: one documentation commit replacing the initial README.

---

### Task 4: Run Final Verification and Publish main

**Files:**
- Verify: all tracked repository files

**Interfaces:**
- Consumes: completed package, installer, README, previews, QA, spec, and plan
- Produces: a verified `origin/main` containing the release-ready pet repository

- [ ] **Step 1: Run the complete repository verification**

Run:

```bash
bash -n scripts/install.sh
jq -e '.id == "mandalorian" and .spriteVersionNumber == 2 and .spritesheetPath == "spritesheet.webp"' pet.json
jq -e '.ok == true and .width == 1536 and .height == 2288 and .rows == 11 and .columns == 8' qa/validation.json
jq -e '.ok == true and .alpha_preserved == true' qa/chroma-despill.json
jq -e '.ok == true and (.directions | length == 16) and ([.directions[].verdict] | all(. != "fail"))' qa/direction-semantics.json
jq -e '.visual_qa == "pass"' qa/final-visual-qa.json
TEST_CODEX_HOME="$(mktemp -d)"
CODEX_HOME="$TEST_CODEX_HOME" ./scripts/install.sh
cmp spritesheet.webp "$TEST_CODEX_HOME/pets/mandalorian/spritesheet.webp"
cmp pet.json "$TEST_CODEX_HOME/pets/mandalorian/pet.json"
! rg -n '/Users/baoxiaopan|direction-blind-answer-key|prompts/' README.md pet.json qa scripts docs/superpowers/specs
```

Expected: all commands exit 0; jq checks print `true`; installed files match byte-for-byte; privacy scan finds no forbidden content.

- [ ] **Step 2: Confirm the exact publishing scope**

Run:

```bash
git status --short
git diff --stat origin/main...HEAD
git log --oneline --decorate origin/main..HEAD
```

Expected: only the approved repository files and intentional commits appear.

- [ ] **Step 3: Push main without rewriting history**

Run:

```bash
git push origin main
```

Expected: `main -> main` succeeds without `--force`.

- [ ] **Step 4: Verify the remote branch**

Run:

```bash
git fetch origin main
test "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)"
git status -sb
```

Expected: local `HEAD` equals `origin/main`; status reports `## main...origin/main` with a clean worktree.
