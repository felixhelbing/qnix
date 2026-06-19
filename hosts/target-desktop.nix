{ ... }:
{
  imports = [
    ../modules/common-target.nix
    ../modules/desktop.nix
  ];

  networking.hostName = "nixos-desktop";
}
