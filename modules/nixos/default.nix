{
  lib,
  hostname,
  stateVersion,
  ...
}:
{
  imports = [
    ./developer.nix
  ];

  networking.hostName = hostname;

  system = {
    stateVersion = lib.mkDefault stateVersion;
  };
}
