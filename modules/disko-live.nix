{ pkgs, ... }:
{
  disko.devices.disk.main = {
    type = "disk";
    # device is irrelevant in image-build mode; imageName/imageSize are used.
    device = "/dev/null";
    imageName = "nixos-live";
    imageSize = "8G";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" "noatime" ];
          };
        };
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptlive";
            # writeText puts "foo" in the build's store; used only at format time,
            # not baked into the runtime initrd.
            passwordFile = "${pkgs.writeText "luks-foo" "foo"}";
            settings.allowDiscards = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "noatime" ];
            };
          };
        };
      };
    };
  };
}
