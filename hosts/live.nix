{ pkgs, lib, inputs, self, ... }:
let
  arch = pkgs.stdenv.hostPlatform.parsed.cpu.name;
  target = self.nixosConfigurations."target-desktop-${arch}";
in
{
  imports = [
    ../modules/base.nix
    ../modules/desktop.nix
    ../modules/install-script.nix
    ../modules/home-q.nix
  ];

  networking.hostName = "nixos-live";

  # Don't touch the host's EFI boot order from the stick
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  documentation.enable = false;

  system.extraDependencies = [
    target.config.system.build.toplevel
    target.config.system.build.diskoScript
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
