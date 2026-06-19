{ pkgs, ... }:
{
  systemd.services.grow-root = {
    description = "Grow root partition, LUKS, and ext4 to fill the disk (live USB)";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    unitConfig.ConditionPathExists = "!/var/lib/grow-root.done";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = with pkgs; [ cloud-utils cryptsetup e2fsprogs util-linux gawk ];
    script = ''
      set -e
      MAP=cryptlive
      [ -e "/dev/mapper/$MAP" ] || exit 0

      LUKS_PART="$(cryptsetup status "$MAP" | awk '/device:/ {print $2}')"
      DISK_NAME="$(lsblk -no PKNAME "$LUKS_PART")"
      PART_NUM="$(echo "$LUKS_PART" | grep -oE '[0-9]+$')"

      growpart "/dev/$DISK_NAME" "$PART_NUM" || true
      cryptsetup resize "$MAP" || true
      resize2fs "/dev/mapper/$MAP" || true

      mkdir -p /var/lib
      touch /var/lib/grow-root.done
    '';
  };
}
