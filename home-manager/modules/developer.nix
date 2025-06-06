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

      nerd-fonts.jetbrains-mono
    ];

    fonts.fontconfig.enable = true;

    programs.bash.shellAliases = {
      git-clean-branches = "git branch --merged | egrep -v '^\s*(\*.*|master|main|dev|develop)$' | xargs git branch -d";
    };

    programs.git = {
      enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        pull.ff = "only";
        fetch.prune = true;
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
