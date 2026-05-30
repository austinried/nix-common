inputs: lib:
let
  mkPkgs = import ./mk-pkgs.nix inputs;

  mkSpecialArgs =
    system:
    {
      inherit system;

      # remove self to prevent unnecessery evaluation when anything changes
      inputs = removeAttrs inputs [ "self" ];
    }
    // mkPkgs system;
in
{
  mkNixos =
    {
      nixpkgs ? inputs.nixpkgs,
      home-manager ? inputs.home-manager,
      system,
      hostname,
      stateVersion,
      users ? [ ],
      specialArgs ? { },
      modules ? [ ],
    }:
    let
      combinedSpecialArgs = {
        inherit hostname stateVersion;
      }
      // mkSpecialArgs system
      // specialArgs;
    in
    nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = combinedSpecialArgs;

      modules = [
        ../../nixos
      ]
      ++ modules
      ++ lib.optionals (users != [ ]) [
        home-manager.nixosModules.home-manager
        ../../nixos/home-manager
        {
          # all nixos-hm modules apply to all users by default
          # can be overridden on this option or on each submodule users option
          common.nixos-hm.users = lib.mkDefault (builtins.map ({ username, ... }: username) users);

          # specialArgs attr set can't be accessed in a nixos module
          home-manager.extraSpecialArgs = combinedSpecialArgs;

          home-manager.users = builtins.listToAttrs (
            builtins.map (
              user:
              assert user.username != null;
              assert if users ? modules then builtins.isList user.modules else true;
              {
                name = user.username;
                value = {
                  # equivilent to per-user specialArgs
                  _module.args = { inherit (user) username; };

                  imports = [
                    ../../home-manager
                  ]
                  ++ lib.optionals (user ? modules) user.modules;
                };
              }
            ) users
          );
        }
      ];
    };

  mkHomeManager =
    {
      nixpkgs ? inputs.home-manager.inputs.nixpkgs,
      home-manager ? inputs.home-manager,
      system,
      username,
      stateVersion,
      modules ? [ ],
      extraSpecialArgs ? { },
    }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { inherit system; };

      extraSpecialArgs = {
        inherit username stateVersion;
      }
      // mkSpecialArgs system
      // extraSpecialArgs;

      modules = [
        ../../home-manager
      ]
      ++ modules;
    };
}
