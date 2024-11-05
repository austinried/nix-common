{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    inherit (self) inputs outputs;

    system = "x86_64-linux";

    pkgs = import nixpkgs { inherit system; };
    pkgs-unstable = import nixpkgs { inherit system; };
  in {
    lib = import ./lib { inherit nixpkgs home-manager; };

    checks.${system}.nixos-test = 
    let
      specialArgs = {
        username = "austin";
        hostname = "machine";
        stateVersion = "24.05";
      };

      nixosConfig = outputs.lib.mkHost specialArgs;
    in pkgs.testers.runNixOSTest {
      name = "nixos-test";
      node.specialArgs = specialArgs;
      nodes.machine = { ... }: {
        imports = nixosConfig._module.args.modules;
      };

      testScript = ''
        machine.start()
        machine.wait_for_unit("default.target")
      '';
    };
  };
}
