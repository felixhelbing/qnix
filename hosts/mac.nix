{ ... }:
{
  imports = [
    ../modules/darwin/base.nix
    ../modules/home/common.nix
    ../modules/home/darwin.nix
  ];

  networking.hostName = "q";
}
