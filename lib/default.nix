importArgs@{ inputs, outputs, nixpkgs, home-manager }:
{
  mkHost = {
    inputs,
    outputs,
    hostname, 
    username ? "austin",
    modules ? [],
    homeModules ? [],
    specialArgs ? {},
    isPhysical ? (isWorkstation || false),
    isWorkstation ? false,
    stateVersion,
  }:
  let
    defaultSpecialArgs = {
      inputs = importArgs.inputs // inputs;
      outputs = importArgs.outputs // outputs;

      inherit
        hostname
        username
        isPhysical
        isWorkstation
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
