{ pkgs, lib, inputs, self, ... }:
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

  # Reduce writes on USB flash
  fileSystems."/".options = [ "noatime" ];
  fileSystems."/boot".options = [ "noatime" ];

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
    root = self;
    fileset = lib.fileset.unions ([
      (self + /flake.nix)
      (self + /hosts)
      (self + /modules)
    ] ++ lib.optional (builtins.pathExists (self + /flake.lock)) (self + /flake.lock));
  };

  environment.systemPackages = with pkgs; [
    pciutils usbutils
  ];

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
  '';
}
