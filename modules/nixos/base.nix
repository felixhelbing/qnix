{ pkgs, nixosRelease, timeZone, locale, keyMap, ... }:
let
  # Default password "foo"; user changes it with `passwd` after first boot.
  initialPasswordHash = "$6$YS1kXnBzqrOq0gb7$cdM5HVELn8kI4JjLiREjrnezPEHjGkeTB15rgCJDyNZxAFTREdK.BAsvMQTf41n047bxdYPiikuKXKPkCaaEv/";
in
{
  system.stateVersion = nixosRelease;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;

  # systemd-initrd so the LUKS prompt has a working keymap
  boot.initrd.systemd.enable = true;
  boot.kernelParams = [ "rd.vconsole.keymap=${keyMap}" ];

  time.timeZone = timeZone;
  i18n.defaultLocale = locale;
  console.keyMap = keyMap;

  networking.networkmanager.enable = true;

  hardware.enableRedistributableFirmware = true;

  users.users.q = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialHashedPassword = initialPasswordHash;
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [ htop ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.journald.extraConfig = "SystemMaxUse=500M";
  zramSwap.enable = true;
}
