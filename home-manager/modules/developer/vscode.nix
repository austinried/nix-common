{
  lib,
  config,
  pkgs,
  pkgs-unfree,
  ...
}:
let
  cfg = config.common.developer.vscode;
in
{
  options.common.developer.vscode = {
    enable = lib.mkEnableOption "VS Code IDE";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;

      mutableExtensionsDir = false;
      extensions = with pkgs.vscode-extensions; [
          mkhl.direnv
          waderyan.gitblame

          dracula-theme.theme-dracula
          pkief.material-icon-theme

          jnoortheen.nix-ide
          denoland.vscode-deno
          esbenp.prettier-vscode
          dart-code.dart-code
          dart-code.flutter
          hashicorp.terraform

          pkgs-unfree.vscode-extensions.mhutchie.git-graph
        ];
    };
  };
}
