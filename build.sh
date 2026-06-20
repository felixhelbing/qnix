#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

nix build .#usbImage -o result --print-build-logs

IMG="$(find -L result -maxdepth 3 -type f \( -name '*.img' -o -name '*.raw' -o -name '*.iso' \) -print -quit)"
if [ -z "$IMG" ]; then
  echo "ERROR: no image produced under result/" >&2
  find -L result -maxdepth 3 -type f >&2
  exit 1
fi

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "image=$IMG" >> "$GITHUB_OUTPUT"
fi

echo ""
echo "Image: $IMG"
