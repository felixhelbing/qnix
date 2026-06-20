{ ... }:
{
  imports = [
    ../modules/nixos/common-target.nix
    ../modules/nixos/desktop.nix
    ../modules/home/common.nix
    ../modules/home/linux.nix
  ];

  networking.hostName = "q";
}
