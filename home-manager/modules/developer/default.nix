{ lib, config, ... }:
let
  cfg = config.common.developer;
in
{
  imports = [
    ./vscode.nix
  ];

  options.common.developer = {
    enable = lib.mkEnableOption "Programs and settings for developers.";
  };

  config = lib.mkIf cfg.enable {
    common.developer.vscode.enable = lib.mkDefault true;
  };
}
