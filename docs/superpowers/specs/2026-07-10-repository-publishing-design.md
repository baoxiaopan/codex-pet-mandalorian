# Mandalorian Codex Pet Repository Publishing Design

Date: 2026-07-10
Status: Approved

## Goal

Publish the verified Mandalorian Codex v2 pet as a small, reusable GitHub repository that is easy to understand, install, validate, and remove.

## Repository Structure

```text
codex-pet-mandalorian/
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
└── docs/superpowers/specs/
    └── 2026-07-10-repository-publishing-design.md
```

The repository contains the installable pet package and a curated public QA set. Internal generation prompts, blind-test answer keys, temporary rows, decoded frames, and other production intermediates are excluded.

## README Contract

The README will include:

- an introduction to the original armored fox-cat code guardian
- a visual preview of the animation atlas and 16 look directions
- compatibility details for Codex v2 pets
- one-command installation and manual installation instructions
- verification, update, and uninstall instructions
- repository structure and QA evidence
- an explicit intellectual-property boundary: the character is original and does not copy protected franchise characters, armor, symbols, lore, or catchphrases

## Installation Flow

`scripts/install.sh` will:

1. resolve the repository root from the script location
2. verify that `pet.json` and `spritesheet.webp` exist
3. verify that `pet.json` declares `id: mandalorian` and `spriteVersionNumber: 2`
4. create `${CODEX_HOME:-$HOME/.codex}/pets/mandalorian`
5. copy both package files together
6. print the installed location and a concise completion message

The script must stop on errors and must not delete unrelated files or modify global Codex configuration.

## Validation

Before publishing:

- validate the atlas as RGBA WebP with 8 columns, 11 rows, and exact dimensions `1536×2288`
- confirm `spriteVersionNumber: 2`
- confirm the curated QA JSON files report successful deterministic and visual checks
- confirm no direction semantic verdict is `fail`
- compare the repository spritesheet hash with the locally verified installed package
- run the installation script against an isolated temporary `CODEX_HOME` and compare installed hashes
- inspect `git status --short` and `git diff --stat` before committing

## Publishing

The completed repository will be committed directly to `main` and pushed to `origin/main`, as explicitly selected by the repository owner. The commit will contain only the pet package, documentation, installer, curated previews, curated QA evidence, and this design record.

## Failure Handling

- Missing or invalid package files block installation and publishing.
- A failed atlas, metadata, hash, installer, or QA check blocks publishing.
- Existing unrelated repository changes must not be staged.
- Git push failures are reported without rewriting history or force-pushing.

## Acceptance Criteria

- A new user can understand the pet and install it from the README.
- `scripts/install.sh` installs both required files into the correct Codex pet directory.
- The published package matches the verified local pet byte-for-byte.
- Public QA evidence is sufficient to confirm v2 compatibility without exposing internal generation artifacts.
- `main` is pushed successfully to `git@github.com:baoxiaopan/codex-pet-mandalorian.git`.
