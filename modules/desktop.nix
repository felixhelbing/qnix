{ pkgs, lib, keyMap, ... }:
{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # PAM service so swaylock can authenticate the user
  security.pam.services.swaylock = {};

  # Latest kernel for newer hardware support
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  users.users.q.extraGroups = [ "video" "audio" "input" ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.thermald.enable = lib.mkDefault true;
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

  environment.etc."sway/config.d/base".text = ''
    set $mod Mod4
    set $term ghostty
    set $menu bemenu-run

    output * bg #1a1b26 solid_color

    input type:keyboard {
        xkb_layout ${keyMap}
    }

    bar {
        position top
    }

    bindsym $mod+Return exec $term
    bindsym $mod+d exec $menu
    bindsym $mod+Shift+q kill
    bindsym $mod+Shift+e exec swaymsg exit
    bindsym $mod+Ctrl+l exec swaylock

    bindsym $mod+h focus left
    bindsym $mod+j focus down
    bindsym $mod+k focus up
    bindsym $mod+l focus right

    bindsym $mod+Shift+h move left
    bindsym $mod+Shift+j move down
    bindsym $mod+Shift+k move up
    bindsym $mod+Shift+l move right

    bindsym $mod+v split vertical
    bindsym $mod+b split horizontal
    bindsym $mod+f fullscreen toggle

    bindsym $mod+1 workspace number 1
    bindsym $mod+2 workspace number 2
    bindsym $mod+3 workspace number 3

    bindsym Print exec grim - | wl-copy
    bindsym Shift+Print exec grim -g "$(slurp)" - | wl-copy

    bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
    bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
    bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle

    bindsym XF86MonBrightnessUp exec brightnessctl set 5%+
    bindsym XF86MonBrightnessDown exec brightnessctl set 5%-

    exec $term
  '';
}
