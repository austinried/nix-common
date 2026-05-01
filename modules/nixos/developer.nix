{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.common.developer;
in
{
  options.common.developer = {
    enable = lib.mkEnableOption "developers";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gnumake
      gcc
      python3
      nodejs_22
    ];
  };
}
