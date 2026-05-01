{
  lib,
  config,
  ...
}:
let
  cfg = config.common.standalone;
in
{
  options.common.standalone = {
    enable = lib.mkEnableOption "Helpers and settings for standalone installations.";
  };

  config = lib.mkIf cfg.enable {
    programs.bash = lib.mkIf config.programs.bash.enable {
      shellAliases = {
        home = "home-manager --override-input nix-common $NIX_COMMON_PATH";
      };
    };
  };
}
