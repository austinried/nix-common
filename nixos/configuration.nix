{
  config,
  lib,
  inputs,
  pkgs,
  username,
  hostname,
  stateVersion,
  isPhysical,
  ...
}:
{
  imports = [ ./modules ];

  networking.hostName = hostname;

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        experimental-features = "flakes nix-command";
        # Disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
        trusted-users = [ "root" ] ++ lib.optionals (username != null) [ username ];
        warn-dirty = false;
      };
      # Disable channels
      channel.enable = false;
      # Make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  environment = {
    systemPackages = with pkgs; [
      git
      micro
      curl
      wget
    ];

    variables = {
      EDITOR = "micro";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };
  };

  programs = {
    nano.enable = lib.mkDefault false;
  };

  services = {
    openssh.enable = true;

    fwupd.enable = isPhysical;
    hardware.bolt.enable = isPhysical;
    smartd.enable = isPhysical;
  };

  users.users = lib.mkIf (username != null) {
    ${username} = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  system.stateVersion = stateVersion;
}
