{ config, lib, inputs, pkgs, username, hostname, stateVersion, isPhysical, ... }: 
{
  imports = [
    ./modules
  ];

  networking.hostName = hostname;

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = "flakes nix-command";
      # Disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
      trusted-users = [
        "root"
        "${username}"
      ];
      warn-dirty = false;
    };
    # Disable channels
    channel.enable = false;
    # Make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # options for testing this config in a VM (nixos-rebuild build-vm)
  virtualisation.vmVariant = {
    i18n.defaultLocale = "en_US.UTF-8";
    console.keyMap = "us";
    
    virtualisation = {
      cores = 4;
      memorySize = 4096;

      # qemu options to get copy/paste and guest integrations working
      # https://discourse.nixos.org/t/get-qemu-guest-integration-when-running-nixos-rebuild-build-vm/22621
      qemu.options = [
        # vga changed to virtio so that auto resize resolution works
        "-vga virtio"
        "-spice port=5930,disable-ticketing=on"
        "-device virtio-serial-pci"
        "-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0"
        "-chardev spicevmc,id=spicechannel0,name=vdagent"
      ];
    };

    # For copy/paste to work
    services.spice-vdagentd.enable = true;
    services.xserver.xkb.layout = "us";
  };

  environment = {
    systemPackages = with pkgs; [
      git
      micro
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
    fwupd.enable = isPhysical;
    hardware.bolt.enable = isPhysical;
    smartd.enable = isPhysical;
  };

  users.users.${username} = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  system.stateVersion = stateVersion;
}
