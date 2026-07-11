#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PET_JSON="$REPO_ROOT/pet.json"
SPRITESHEET="$REPO_ROOT/spritesheet.webp"
CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"
PET_DIR="$CODEX_ROOT/pets/mandalorian"
STAGED_PET_JSON=""
STAGED_SPRITESHEET=""

cleanup() {
  if [[ -n "$STAGED_PET_JSON" ]]; then
    rm -f -- "$STAGED_PET_JSON"
  fi
  if [[ -n "$STAGED_SPRITESHEET" ]]; then
    rm -f -- "$STAGED_SPRITESHEET"
  fi
}

trap cleanup EXIT HUP INT TERM

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
STAGED_PET_JSON="$(mktemp "$PET_DIR/.pet.json.tmp.XXXXXX")"
STAGED_SPRITESHEET="$(mktemp "$PET_DIR/.spritesheet.webp.tmp.XXXXXX")"

cp -- "$PET_JSON" "$STAGED_PET_JSON"
cp -- "$SPRITESHEET" "$STAGED_SPRITESHEET"

if ! jq -e '.id == "mandalorian" and .spriteVersionNumber == 2 and .spritesheetPath == "spritesheet.webp"' "$STAGED_PET_JSON" >/dev/null; then
  echo "Staged pet.json is not a valid Mandalorian v2 pet manifest." >&2
  exit 1
fi

if ! cmp -s -- "$PET_JSON" "$STAGED_PET_JSON"; then
  echo "Staged pet.json does not match its source." >&2
  exit 1
fi

if ! cmp -s -- "$SPRITESHEET" "$STAGED_SPRITESHEET"; then
  echo "Staged spritesheet.webp does not match its source." >&2
  exit 1
fi

mv -f -- "$STAGED_SPRITESHEET" "$PET_DIR/spritesheet.webp"
STAGED_SPRITESHEET=""
mv -f -- "$STAGED_PET_JSON" "$PET_DIR/pet.json"
STAGED_PET_JSON=""

echo "Installed Mandalorian to $PET_DIR"
