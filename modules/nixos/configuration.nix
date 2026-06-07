# TODO: refactor this into smaller modules that make more sense
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    lib.mkDefault {
      optimise = {
        automatic = true;
        dates = [ "03:45" ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      settings = {
        experimental-features = "nix-command flakes";
        # Disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
        trusted-users = [ "root" ];
        warn-dirty = false;
      };
      # Disable channels
      channel.enable = false;
      # Make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  # Clean up channels leftovers
  system.activationScripts.removeStaleChannels = ''
    rm -f /root/.nix-defexpr/channels
    rm -f /nix/var/nix/profiles/per-user/root/channels \
          /nix/var/nix/profiles/per-user/root/channels-*-link
  '';

  environment.systemPackages = with pkgs; [
    git
    jq

    curl
    wget

    pciutils
    inetutils
    usbutils
    lsof

    wireguard-tools
  ];

  programs = {
    nano.enable = lib.mkDefault false;
  };

  services = {
    openssh.enable = true;
  };
}
