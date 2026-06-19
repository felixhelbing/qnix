#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

nix build .#usbImage -o result --print-build-logs

IMG="$(find -L result -maxdepth 2 -name '*.img' -print -quit)"
if [ -z "$IMG" ]; then
  echo "ERROR: no .img produced under result/" >&2
  exit 1
fi

echo ""
echo "Image: $IMG"
echo ""
echo "Flash with:"
echo "  sudo dd if=$IMG of=/dev/sdX bs=4M status=progress conv=fsync"
