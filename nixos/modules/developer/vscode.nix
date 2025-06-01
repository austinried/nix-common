{
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.common.developer.vscode;
in
{
  options.common.developer.vscode = {
    enable = lib.mkEnableOption "Visual Studio Code IDE";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      {
        pkgs,
        pkgs-unfree,
        ...
      }:
      {
        programs.vscode = {
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
  };
}
