{ lib, isWorkstation, ... }:
{
  imports =
    [ ]
    ++ lib.optionals isWorkstation [
      ./vscode.nix
      ./firefox.nix
    ];
}
