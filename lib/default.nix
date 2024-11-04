{ nixpkgs, home-manager }:
{
  mkHost = {
    hostname, 
    username ? "austin",
    modules ? [],
    homeModules ? [],
    specialArgs ? {},
    stateVersion,
  }:
  let
    defaultSpecialArgs = {
      inherit
        hostname
        username
        stateVersion;
    };
  in nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = defaultSpecialArgs // specialArgs;

    modules = [
      ../nixos/configuration.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${username} = { ... }: {
          imports = [
            ../home-manager/home.nix
          ] ++ homeModules;
        };

        home-manager.extraSpecialArgs = defaultSpecialArgs // specialArgs;
      }
    ] ++ modules;
  };
}
