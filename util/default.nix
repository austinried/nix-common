importArgs@{
  inputs,
  nixpkgs,
  pkgs-unstable,
  pkgs-unfree,
  pkgs-unfree-unstable,
  home-manager,
}:
{
  mkHost =
    {
      inputs,

      hostname,
      username ? null,

      modules ? [ ],
      homeModules ? [ ],
      specialArgs ? { },

      isPhysical ? false,

      stateVersion,
    }:
    let
      defaultSpecialArgs = {
        inputs = importArgs.inputs // inputs;

        inherit
          pkgs-unstable
          pkgs-unfree
          pkgs-unfree-unstable
          hostname
          username
          isPhysical
          stateVersion
          ;
      };
    in
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = defaultSpecialArgs // specialArgs;

      modules = [
        ../nixos/configuration.nix
      ]
      ++ modules
      ++ nixpkgs.lib.optionals (username != null) [
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm.bak";

          home-manager.extraSpecialArgs = defaultSpecialArgs // specialArgs;

          home-manager.users.${username} = {
            imports = [ ../home-manager/home.nix ] ++ homeModules;
          };
        }
      ];
    };
}
