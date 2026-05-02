{
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
    inherit stateVersion;
  };
}
