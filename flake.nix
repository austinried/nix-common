{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs { inherit system; };
    pkgs-unstable = import nixpkgs { inherit system; };
  in {
    nixosModules = {
      default = { pkgs, ... }: {
        environment.systemPackages = [ ];
      };
    };
  };
}
