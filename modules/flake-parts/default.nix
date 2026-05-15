{
  imports = [
    ./common
    ./checks
    ./nixd.nix
    ./shell.nix
  ];

  systems = [ "x86_64-linux" ];

  flake = {
    flakeModules.default = import ./common;
    flakeModules.nixd = import ./nixd.nix;

    nixosModules.default = import ../nixos;

    homeModules.default = import ../home-manager;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.run-nixos-vm = pkgs.callPackage ../../packages/run-nixos-vm { };
      packages.dconf-mirror = pkgs.callPackage ../../packages/dconf-mirror { };
    };
}
