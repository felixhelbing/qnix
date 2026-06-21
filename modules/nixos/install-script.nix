{ pkgs, ... }:
let
  arch = pkgs.stdenv.hostPlatform.parsed.cpu.name;
  offlineFlag = if arch == "x86_64" then "--option substitute false" else "";
  installScript = pkgs.writeShellApplication {
    name = "install-to-disk";
    runtimeInputs = with pkgs; [
      util-linux
      gum
      coreutils
      disko
    ];
    text = ''
      set -euo pipefail

      die() { gum style --foreground 196 "ERROR: $*" >&2; exit 1; }

      cleanup() { shred -u /tmp/disk.key 2>/dev/null || rm -f /tmp/disk.key 2>/dev/null || true; }
      trap cleanup EXIT

      [ -d /dev/disk/by-id ] || die "/dev/disk/by-id missing"

      ROOT_SRC="$(findmnt -n -o SOURCE /)"
      BOOT_DEV="$(lsblk -spnlo NAME "$ROOT_SRC" 2>/dev/null | tail -1)"
      [ -z "$BOOT_DEV" ] && BOOT_DEV="$ROOT_SRC"
      BOOT_DEV_REAL="$(realpath "$BOOT_DEV" 2>/dev/null || echo "$BOOT_DEV")"

      shopt -s nullglob

      CANDIDATES=()
      while IFS= read -r NAME; do
        DEV="/dev/$NAME"
        REAL="$(realpath "$DEV" 2>/dev/null || echo "$DEV")"
        [ "$REAL" = "$BOOT_DEV_REAL" ] && continue
        BY_ID=""
        for id_path in /dev/disk/by-id/*; do
          id="''${id_path##*/}"
          [[ "$id" =~ -part[0-9]+$ ]] && continue
          target="$(realpath "$id_path" 2>/dev/null || true)"
          if [ "$target" = "$REAL" ]; then BY_ID="$id"; break; fi
        done
        if [ -n "$BY_ID" ]; then
          DISK_PATH="/dev/disk/by-id/$BY_ID"
        else
          DISK_PATH="$DEV"
        fi
        SIZE="$(lsblk -dno SIZE "$DEV")"
        MODEL="$(lsblk -dno MODEL "$DEV" | sed 's/  */ /g')"
        SERIAL="$(lsblk -dno SERIAL "$DEV")"
        CANDIDATES+=("$(printf '%s\t%s\t%s %s' "$DISK_PATH" "$SIZE" "$MODEL" "$SERIAL")")
      done < <(lsblk -dno NAME,TRAN,TYPE | awk '$3=="disk" && $2!="usb" {print $1}')
      [ ''${#CANDIDATES[@]} -eq 0 ] && die "no eligible disks"

      LABELS=()
      for c in "''${CANDIDATES[@]}"; do
        IFS=$'\t' read -r BY_ID SIZE DESC <<< "$c"
        LABELS+=("$BY_ID  [$SIZE]  $DESC")
      done

      if [ ''${#LABELS[@]} -eq 1 ]; then
        SELECTION="''${LABELS[0]}"
      else
        SELECTION="$(gum choose --header "Target disk:" "''${LABELS[@]}")"
      fi
      DISK="$(echo "$SELECTION" | awk '{print $1}')"

      [ "$(realpath "$DISK")" = "$BOOT_DEV_REAL" ] && die "selected disk is boot medium"

      lsblk "$DISK"
      CONFIRM="$(gum input --placeholder "Type DELETE to wipe $DISK")"
      [ "$CONFIRM" = "DELETE" ] || die "aborted"

      umask 077
      printf 'foo' > /tmp/disk.key

      disko-install \
        --flake "/etc/live#target-desktop-${arch}" \
        --disk main "$DISK" \
        --no-root-passwd \
        --write-efi-boot-entries \
        ${offlineFlag}

      gum confirm --default=no "Reboot?" && systemctl reboot
    '';
  };
in
{
  environment.systemPackages = [ installScript ];
}
