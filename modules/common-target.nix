{ pkgs, lib, ... }:
{
  imports = [
    ./base.nix
    ./disko-target.nix
    ./home-q.nix
  ];

  networking.hostName = lib.mkDefault "nixos";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.fstrim.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  environment.systemPackages = with pkgs; [ curl wget ];
}
