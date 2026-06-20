{ pkgs, inputs, self, ... }:
let
  arch = pkgs.stdenv.hostPlatform.parsed.cpu.name;
  target = self.nixosConfigurations."target-desktop-${arch}";
in
{
  system.extraDependencies = [
    target.config.system.build.toplevel
    target.config.system.build.diskoScript
    inputs.nixpkgs
    inputs.disko
    inputs.home-manager
  ];
}
