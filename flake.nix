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
    nixosRelease = "25.05";
    keyMap     = "us";
    timeZone   = "Europe/Berlin";
    locale     = "en_US.UTF-8";
    commonArgs = { inherit inputs self nixosRelease keyMap timeZone locale; };

    hostModules = [
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = commonArgs;
      }
    ];

    # Target-Install always uses disko (LUKS on installed disk regardless of arch)
    desktopModules = hostModules ++ [
      disko.nixosModules.disko
      ./hosts/target-desktop.nix
    ];

    # Live for x86: disko-based, LUKS on stick (KVM available on x86 runner)
    liveModulesX86 = hostModules ++ [
      disko.nixosModules.disko
      ./modules/disko-live.nix
      ./hosts/live.nix
    ];

    # Live for aarch64: nixos-generators raw-efi, no LUKS on stick
    # (ARM runner has no KVM, can't do disko image build)
    liveModulesAarch64 = hostModules ++ [
      ./hosts/live.nix
    ];

    mkSystem = system: modules: nixpkgs.lib.nixosSystem {
      inherit system modules;
      specialArgs = commonArgs;
    };
  in
  {
    nixosConfigurations = {
      live-x86_64           = mkSystem "x86_64-linux"  liveModulesX86;
      live-aarch64          = mkSystem "aarch64-linux" liveModulesAarch64;
      target-desktop-x86_64 = mkSystem "x86_64-linux"  desktopModules;
      target-desktop-aarch64 = mkSystem "aarch64-linux" desktopModules;
    };

    packages.x86_64-linux.usbImage =
      self.nixosConfigurations.live-x86_64.config.system.build.diskoImages;

    packages.aarch64-linux.usbImage = nixos-generators.nixosGenerate {
      system = "aarch64-linux";
      specialArgs = commonArgs;
      modules = liveModulesAarch64;
      format = "raw-efi";
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt-rfc-style;
  };
}
