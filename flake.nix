{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
  let
    inherit (self) outputs;

    system = "x86_64-linux";

    pkgs = import nixpkgs { inherit system; };
    pkgs-unstable = import nixpkgs { inherit system; };
  in {
    # nixosModules = import ./nixos;
    # homeManagerModules = import ./home-manager;
    lib = import ./lib { inherit nixpkgs home-manager; };
  };
}
