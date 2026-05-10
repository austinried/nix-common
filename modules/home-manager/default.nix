{
  lib,
  username,
  stateVersion,
  pkgs,
  ...
}:
{
  imports = [
    ./developer.nix
    ./shell.nix
    ./standalone.nix
    ./vscode.nix
    ./terminal.nix
    ./japanese.nix
    ./yadm.nix
  ];

  home = {
    inherit username stateVersion;

    homeDirectory = lib.mkDefault (
      if pkgs.stdenv.isLinux then
        "/home/${username}"
      else if pkgs.stdenv.isDarwin then
        "/Users/${username}"
      else
        null
    );
  };
}
