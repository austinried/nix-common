args:
import ./mk-module args "vscode" {
  config =
    { cfg, perUser, ... }:
    {
      home-manager.users = perUser (
        username:
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
        }
      );
    };
}
