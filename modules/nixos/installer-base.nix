{ pkgs, lib, inputs, ... }:
{
  imports = [
    ./base.nix
    ./install-script.nix
  ];

  networking.hostName = "q";

  # Live/installer must not touch the host's EFI boot order
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  documentation.enable = false;

  nix.registry = {
    nixpkgs.flake = inputs.nixpkgs;
    disko.flake = inputs.disko;
    home-manager.flake = inputs.home-manager;
  };

  environment.etc."live".source = lib.fileset.toSource {
    root = ../../.;
    fileset = lib.fileset.unions ([
      ../../flake.nix
      ../../hosts
      ../../modules
    ] ++ lib.optional (builtins.pathExists ../../flake.lock) ../../flake.lock);
  };

  environment.systemPackages = with pkgs; [ pciutils usbutils ];

  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
  };
}
