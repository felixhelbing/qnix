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
    };

    programs.git = {
      enable = true;
      # user.name / user.email to be filled in
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    xdg.configFile."ghostty/config".text = ''
      font-size = 12
    '';
  };
}
