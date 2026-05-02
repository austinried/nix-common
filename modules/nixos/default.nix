{
  lib,
  hostname,
  stateVersion,
  ...
}:
{
  imports = [
    ./configuration.nix
    ./developer.nix
  ];

  networking.hostName = hostname;

  system = {
    stateVersion = lib.mkDefault stateVersion;
  };
}
