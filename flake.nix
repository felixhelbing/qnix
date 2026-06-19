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
    system = "x86_64-linux";
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
  in
  {
    nixosConfigurations = {
      live = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonArgs;
        modules = liveModules;
      };
      target-desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonArgs;
        modules = desktopModules;
      };
    };

    packages.${system}.usbImage =
      self.nixosConfigurations.live.config.system.build.diskoImages;

    formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
  };
}
