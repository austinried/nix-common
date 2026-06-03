{
  lib,
  config,
  pkgs,
  pkgs-unfree,
  ...
}:
let
  cfg = config.common.vscodium;
in
{
  options.common.vscodium = {
    enable = lib.mkEnableOption "Visual Studio Code IDE";
  };

  config = lib.mkIf cfg.enable {
    programs.vscodium = {
      enable = true;
      package = pkgs.vscodium;

      mutableExtensionsDir = false;

      profiles.default.extensions = with pkgs.vscode-extensions; [
        mkhl.direnv
        editorconfig.editorconfig
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
