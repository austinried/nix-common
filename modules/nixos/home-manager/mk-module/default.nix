args@{ lib, ... }:
name:
{
  imports ? [ ],
  options ? { },
  config ? { },
}:
let
  cfg = args.config.common.nixos-hm.${name};
  util = import ./util.nix lib;
in
{
  inherit imports;

  options.common.nixos-hm.${name} = lib.recursiveUpdate {
    enable = lib.mkEnableOption name;
    users = util.mkUsersOption name;
  } options;

  config =
    let
      users = util.mkUsers args.config name;
    in
    lib.mkIf cfg.enable (
      if (builtins.isFunction config) then
        (config {
          inherit cfg;

          perUser = util.perUser users;
        })
      else
        config
    );
}
