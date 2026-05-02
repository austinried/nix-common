{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    templates.url = "github:NixOS/templates";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [
          ./checks
          ./modules/flake-parts
          ./modules/flake-parts/internal
        ];

        systems = [ "x86_64-linux" ];

        flake = {
          flakeModules.default = import ./modules/flake-parts;
          nixosModules.default = import ./modules/nixos;
          homeModules.default = import ./modules/home-manager;
        };

        perSystem =
          { pkgs, ... }:
          {
            packages = {
              run-nixos-vm = pkgs.writeShellApplication {
                name = "run-nixos-vm";
                runtimeInputs = [ pkgs.virt-viewer ];
                text = ''
                  "./result/bin/run-$1-vm" & PID_QEMU="$!"
                  sleep 1 # I think some tools have an option to wait like -w
                  remote-viewer spice://127.0.0.1:5930
                  kill $PID_QEMU
                '';
              };
            };
          };
      }
    );
}
