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

  # Force USB storage modules early; rootdelay gives USB enumeration time
  # after UEFI→kernel handoff; autosuspend off prevents stick going idle.
  boot.initrd.kernelModules = [ "usb_storage" "uas" ];
  boot.kernelParams = [
    "rd.vconsole.keymap=${keyMap}"
    "rootdelay=10"
    "usbcore.autosuspend=-1"
  ];

  # Diagnostic tools available in initrd emergency shell
  boot.initrd.systemd.extraBin = {
    lsblk = "${pkgs.util-linux}/bin/lsblk";
    dmesg = "${pkgs.util-linux}/bin/dmesg";
    grep  = "${pkgs.gnugrep}/bin/grep";
    lsusb = "${pkgs.usbutils}/bin/lsusb";
  };

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
  users.users.root.hashedPassword = initialPasswordHash;
  boot.initrd.systemd.emergencyAccess = true;

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [ htop ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.journald.extraConfig = "SystemMaxUse=500M";
  zramSwap.enable = true;
}
