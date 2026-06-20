{
  description = "NixOS Live Image";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, disko, home-manager, ... }@inputs:
  let
    nixosRelease = "25.05";
    keyMap     = "us";
    timeZone   = "Europe/Berlin";
    locale     = "en_US.UTF-8";
    commonArgs = { inherit inputs self nixosRelease keyMap timeZone locale; };

    baseModules = [
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = commonArgs;
      }
      disko.nixosModules.disko
    ];

    liveModules = baseModules ++ [
      ./modules/disko-live.nix
      ./hosts/live.nix
    ];
    desktopModules = baseModules ++ [
      ./hosts/target-desktop.nix
    ];

    mkPair = system: shortArch: {
      "live-${shortArch}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonArgs;
        modules = liveModules;
      };
      "target-desktop-${shortArch}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonArgs;
        modules = desktopModules;
      };
    };
  in
  {
    nixosConfigurations =
      mkPair "x86_64-linux" "x86_64"
      // mkPair "aarch64-linux" "aarch64";

    packages.x86_64-linux.usbImage =
      self.nixosConfigurations.live-x86_64.config.system.build.diskoImages;
    packages.aarch64-linux.usbImage =
      self.nixosConfigurations.live-aarch64.config.system.build.diskoImages;

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt-rfc-style;
  };
}
