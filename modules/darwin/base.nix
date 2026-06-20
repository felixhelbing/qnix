{ pkgs, ... }:
{
  system.stateVersion = 5;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.primaryUser = "q";
  users.users.q.home = "/Users/q";

  programs.zsh.enable = true;

  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 14;
      KeyRepeat = 1;
    };
    dock = {
      autohide = true;
      show-recents = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
    };
  };

  environment.systemPackages = with pkgs; [ htop ];
}
