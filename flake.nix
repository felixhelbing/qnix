{
  description = "qNixOs — Linux + macOS";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nix-darwin, disko, home-manager, nixos-generators, ... }@inputs:
  let
    nixosRelease = "25.05";
    keyMap     = "us";
    timeZone   = "Europe/Berlin";
    locale     = "en_US.UTF-8";
    commonArgs = { inherit inputs self nixosRelease keyMap timeZone locale; };

    hmNixosModule = home-manager.nixosModules.home-manager;
    hmDarwinModule = home-manager.darwinModules.home-manager;
    hmConfig = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = commonArgs;
    };

    nixosBaseModules = [ hmNixosModule hmConfig ];

    desktopModules = nixosBaseModules ++ [
      disko.nixosModules.disko
      ./hosts/target-desktop.nix
    ];

    liveModulesX86 = nixosBaseModules ++ [
      disko.nixosModules.disko
      ./modules/nixos/disko-live.nix
      ./hosts/live.nix
    ];

    installerModulesAarch64 = nixosBaseModules ++ [
      ./hosts/installer.nix
    ];

    mkNixos = system: modules: nixpkgs.lib.nixosSystem {
      inherit system modules;
      specialArgs = commonArgs;
    };
  in
  {
    nixosConfigurations = {
      live-x86_64            = mkNixos "x86_64-linux"  liveModulesX86;
      target-desktop-x86_64  = mkNixos "x86_64-linux"  desktopModules;
      target-desktop-aarch64 = mkNixos "aarch64-linux" desktopModules;
    };

    darwinConfigurations.q = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = commonArgs;
      modules = [
        hmDarwinModule
        hmConfig
        ./hosts/mac.nix
      ];
    };

    packages.x86_64-linux.usbImage =
      self.nixosConfigurations.live-x86_64.config.system.build.diskoImages;

    packages.aarch64-linux.usbImage = nixos-generators.nixosGenerate {
      system = "aarch64-linux";
      specialArgs = commonArgs;
      modules = installerModulesAarch64;
      format = "iso";
    };

    formatter.x86_64-linux   = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    formatter.aarch64-linux  = nixpkgs.legacyPackages.aarch64-linux.nixfmt-rfc-style;
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
  };
}
