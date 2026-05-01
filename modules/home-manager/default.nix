{
  lib,
  username,
  stateVersion,
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
  ];

  home = {
    inherit username;

    stateVersion = lib.mkDefault stateVersion;
  };
}
