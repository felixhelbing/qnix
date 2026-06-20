{ pkgs, lib, ... }:
{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  security.pam.services.swaylock = {};

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  users.users.q.extraGroups = [ "video" "audio" "input" ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.thermald.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isx86_64;
  services.tlp.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    ghostty
    grim
    slurp
    wl-clipboard
    bemenu
    swaylock
    brightnessctl
    brave
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    font-awesome
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
