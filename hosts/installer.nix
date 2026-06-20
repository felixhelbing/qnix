{ ... }:
{
  imports = [
    ../modules/nixos/installer-base.nix
  ];

  services.getty.autologinUser = "q";
}
