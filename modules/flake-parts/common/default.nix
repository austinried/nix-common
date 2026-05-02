{ inputs, lib, ... }:
let
  mkPkgs = import ./mk-pkgs.nix inputs;
  inherit (import ./mk-configs.nix inputs lib) mkNixos mkHomeManager;
in
{
  _module.args.common = {
    inherit mkPkgs mkNixos mkHomeManager;
  };

  perSystem =
    { system, ... }:
    {
      _module.args = mkPkgs system;
    };
}
