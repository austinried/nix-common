{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    inherit (self) inputs outputs;

    system = "x86_64-linux";

    pkgs = import nixpkgs { inherit system; };
    pkgs-unstable = import nixpkgs { inherit system; };
    pkgs-unfree = import nixpkgs { inherit system; config.allowUnfree = true; };
  in {
    lib = import ./lib {
      inherit
        inputs
        outputs
        nixpkgs
        pkgs-unstable
        pkgs-unfree
        home-manager;
    };

    packages.${system} = {
      # Helper script to run VM and connect to the spice display for copy/paste support
      # Relies on the virtualisation config in file://./nixos/modules/vm.nix
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
