{
  lib,
  config,
  inputs,
  ...
}:
{
  nix.gc = lib.mkDefault {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.optimise = lib.mkDefault {
    automatic = true;
    dates = [ "03:45" ];
  };

  # Disable channels
  nix.channel.enable = false;

  # Make flake registry and nix path match flake inputs nixpkgs
  nix.registry = {
    nixpkgs.flake = inputs.nixpkgs;
  };
  nix.nixPath = [
    "nixpkgs=flake:nixpkgs"
  ];

  nix.settings = {
    experimental-features = "nix-command flakes";
    warn-dirty = false;

    # Disable global registry
    flake-registry = "";

    # Workaround for https://github.com/NixOS/nix/issues/9574
    nix-path = config.nix.nixPath;
  };

  # Clean up channels leftovers
  system.activationScripts.removeStaleChannels = ''
    rm -f /root/.nix-defexpr/channels
    rm -f /nix/var/nix/profiles/per-user/root/channels \
          /nix/var/nix/profiles/per-user/root/channels-*-link
  '';
}
