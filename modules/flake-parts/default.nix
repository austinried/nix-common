{
  imports = [
    ./common
    ./checks
    ./packages
    ./nixd.nix
  ];

  systems = [ "x86_64-linux" ];

  flake = {
    flakeModules.default = import ./common;
    flakeModules.nixd = import ./nixd.nix;

    nixosModules.default = import ../nixos;

    homeModules.default = import ../home-manager;
  };
}
