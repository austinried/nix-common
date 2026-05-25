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
    enable = lib.mkEnableOption "Programs and settings for developers.";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nixd
      nil
      nixfmt
      nh
      nix-output-monitor
      dix

      nerd-fonts.jetbrains-mono
    ];

    fonts.fontconfig.enable = true;

    programs.bash.shellAliases = {
      git-clean-branches = "git branch --merged | egrep -v '^s*(*.*|master|main|dev|develop)$' | xargs git branch -d";
    };

    programs.git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        pull.ff = "only";
        fetch.prune = true;
        rerere.enabled = true;
      };
    };

    programs.gitui = {
      enable = true;
    };

    programs.lazygit = {
      enable = true;
      settings = {
        gui = {
          nerdFontsVersion = "3";
          showFileIcons = true;
        };
        git = {
          pagers = [
            { pager = "diff-so-fancy"; }
          ];
        };
      };
    };

    programs.diff-so-fancy = {
      enable = true;
      enableGitIntegration = true;
      settings = {
        semIntegration = true;
      };
    };

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    programs.mise = {
      enable = true;
    };
  };
}
