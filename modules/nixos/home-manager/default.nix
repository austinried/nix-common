# this module provides nixos modules that also configure home-manager modules.
# these home-manager modules are only intended to be used on nixos due to:
#   - dependence on system-level config provided by the nixos module
#   - poor experience on non-nixos systems (gui apps, etc.)
#
# this module should NOT be imported by default into the larger nixos module
# hierarchy due to its dependence on the nixos home-manager module, and should
# instead be imported only when home-manger is used on the system.
{ lib, config, ... }:
let
  util = import ./mk-module/util.nix lib;
in
{
  imports = [
    ./android.nix
    ./firefox.nix
    ./gnome.nix
    ./japanese.nix
    ./terminal.nix
    ./vscode.nix
  ];

  options.common.nixos-hm = {
    users = (util.mkUsersOption "nixos-hm") // {
      description = "";
    };
  };

  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "hm.bak";

    # home-manager only works for normal users that exist in the system config
    users.users = util.perUser (builtins.attrNames config.home-manager.users) (username: {
      isNormalUser = lib.mkDefault true;
    });
  };
}
