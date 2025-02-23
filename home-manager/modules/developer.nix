{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.common.developer;
in
{
  options.common.developer = {
    enable = lib.mkEnableOption "Programs and settings for developers.";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nixd
      nil
      nixfmt-rfc-style

      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

    fonts.fontconfig.enable = true;

    programs.git = {
      enable = true;
      extraConfig = {
        init.defaultBranch = "main";
      };
    };

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    programs.mise = {
      enable = true;
      package = pkgs-unstable.mise;
    };
  };
}
