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
