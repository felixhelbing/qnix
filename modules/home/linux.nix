{ keyMap, ... }:
{
  home-manager.users.q = {
    programs.bash.profileExtra = ''
      if [ -z "''${WAYLAND_DISPLAY:-}" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec sway
      fi
    '';

    wayland.windowManager.sway = {
      enable = true;
      config = null;
      extraConfig = ''
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

        bindsym $mod+Return  exec $term
        bindsym $mod+d       exec $menu
        bindsym $mod+Shift+q kill
        bindsym $mod+Shift+e exec swaymsg exit
        bindsym $mod+Ctrl+l  exec swaylock

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

        bindsym Print       exec grim - | wl-copy
        bindsym Shift+Print exec grim -g "$(slurp)" - | wl-copy

        bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
        bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
        bindsym XF86AudioMute        exec pactl set-sink-mute   @DEFAULT_SINK@ toggle

        bindsym XF86MonBrightnessUp   exec brightnessctl set 5%+
        bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
      '';
    };
  };
}
