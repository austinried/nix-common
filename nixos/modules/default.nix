{ lib, isWorkstation, ...}:
{
  imports = [
    ./vm.nix
  ]
  ++ lib.optionals isWorkstation [
    ./gnome.nix
  ];
}
