{ ... }:
{
  imports = [
    ../modules/nixos/installer-base.nix
    ../modules/nixos/installer-offline.nix
    ../modules/nixos/desktop.nix
    ../modules/home/common.nix
    ../modules/home/linux.nix
  ];
}
