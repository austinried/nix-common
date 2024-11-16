{ lib, isWorkstation, ...}:
{
  imports = [ ]
  ++ lib.optionals isWorkstation [
    ./gnome.nix
  ];
}
