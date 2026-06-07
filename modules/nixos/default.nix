{ hostname, ... }:
{
  imports = [
    ./configuration.nix
    ./developer.nix
    ./nix.nix
  ];

  networking.hostName = hostname;
}
