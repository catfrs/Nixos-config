{inputs, self, ...}: {
  flake.nixosModules.roxysu = {
    pkgs,
    lib,
    config,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    roxysuPkg = inputs.roxysu.packages.${system}.roxysu;
  in {
    environment.systemPackages = [roxysuPkg];
  };

  perSystem = {system, ...}: {
    packages.roxysu = inputs.roxysu.packages.${system}.roxysu;
  };
}