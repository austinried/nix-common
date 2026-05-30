{ hostname, ... }:
{
  imports = [
    ./configuration.nix
    ./developer.nix
  ];

  networking.hostName = hostname;
}
