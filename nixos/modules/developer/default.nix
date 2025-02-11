{
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.common.developer;
in
{
  imports = [
    ./android.nix
  ];

  options.common.developer = {
    enable = lib.mkEnableOption "Programs and settings for developers.";
  };

  config = lib.mkIf cfg.enable {
    common.developer.android.enable = lib.mkDefault true;

    home-manager.users.${username} =
      { pkgs, pkgs-unfree, ... }:
      {
        home.packages = with pkgs; [
          nixd
          nil
          nixfmt-rfc-style

          sqlitebrowser
        ];

        programs.git = {
          enable = true;
          extraConfig = {
            init.defaultBranch = "main";
          };
        };

        programs.direnv.enable = true;
        programs.direnv.nix-direnv.enable = true;
      };
  };
}
