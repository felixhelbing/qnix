{ pkgs, lib, inputs, self, ... }:
{
  imports = [
    ../modules/base.nix
    ../modules/desktop.nix
    ../modules/install-script.nix
    ../modules/home-q.nix
    ../modules/grow-root.nix
  ];

  networking.hostName = "nixos-live";

  # Don't touch the host's EFI boot order from the stick
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  documentation.enable = false;

  system.extraDependencies = [
    self.nixosConfigurations.target-desktop.config.system.build.toplevel
    self.nixosConfigurations.target-desktop.config.system.build.diskoScript
    inputs.nixpkgs
    inputs.disko
    inputs.home-manager
  ];

  # Resolve flake inputs from local store instead of fetching
  nix.registry = {
    nixpkgs.flake = inputs.nixpkgs;
    disko.flake = inputs.disko;
    home-manager.flake = inputs.home-manager;
  };

  environment.etc."live".source = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions ([
      ../flake.nix
      ../hosts
      ../modules
    ] ++ lib.optional (builtins.pathExists ../flake.lock) ../flake.lock);
  };

  environment.systemPackages = with pkgs; [
    pciutils usbutils
  ];

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
  '';
}
