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
  imports = [
    ./vscode.nix
  ];

  options.common.developer = {
    enable = lib.mkEnableOption "Programs and settings for developers.";
  };

  config = lib.mkIf cfg.enable {
    common.developer.vscode.enable = lib.mkDefault true;

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

    programs.mise.enable = true;
  };
}
