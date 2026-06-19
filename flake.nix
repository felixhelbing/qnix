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
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, disko, home-manager, nixos-generators, ... }@inputs:
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
    ];

    liveModules = baseModules ++ [ ./hosts/live.nix ];
    targetDesktopModules = baseModules ++ [
      disko.nixosModules.disko
      ./hosts/target-desktop.nix
    ];

    mkSystem = modules: nixpkgs.lib.nixosSystem {
      inherit system modules;
      specialArgs = commonArgs;
    };
  in
  {
    nixosConfigurations = {
      live = mkSystem liveModules;
      target-desktop = mkSystem targetDesktopModules;
    };

    packages.${system}.usbImage = nixos-generators.nixosGenerate {
      inherit system;
      specialArgs = commonArgs;
      modules = liveModules;
      format = "raw-efi";
    };

    formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
  };
}
