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
  nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = {
      inherit
        hostname
        username
        stateVersion;
    } // specialArgs;

    modules = [
      ../nixos
      home-manager.nixosModules.home-manager
      {
        system.stateVersion = stateVersion;

        users.users.${username} = {
          isNormalUser = true;
        };

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${username} = { ... }: {
          imports = [
            ../home-manager/home.nix
          ] ++ homeModules;
        };

        # Optionally, use home-manager.extraSpecialArgs to pass
        # arguments to home.nix
        # home-manager.extraSpecialArgs = 
      }
    ] ++ modules;
  };
}
