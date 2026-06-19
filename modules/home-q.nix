{ nixosRelease, ... }:
{
  home-manager.users.q = {
    home.stateVersion = nixosRelease;

    programs.bash = {
      enable = true;
      shellAliases = {
        ll = "ls -lah";
        gs = "git status";
        gd = "git diff";
      };
      profileExtra = ''
        if [ -z "''${WAYLAND_DISPLAY:-}" ] && [ "$(tty)" = "/dev/tty1" ]; then
          exec sway
        fi
      '';
    };

    xdg.configFile."ghostty/config".text = ''
      font-size = 12
    '';
  };
}
