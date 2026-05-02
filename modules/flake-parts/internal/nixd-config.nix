# Configurations and settings to use with nixd for completions. Point the LSP
# here in VS Code's settings.json nixd options.
# https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
{ common, ... }:
{
  debug = true;

  flake.nixosConfigurations.nixd = common.mkNixos {
    system = "x86_64-linux";
    hostname = "test";
    stateVersion = "25.11";
    modules = [
      {
        boot.loader.systemd-boot.enable = true;
        fileSystems."/".device = "/dev/sda1";
        fileSystems."/".fsType = "ext4";
      }
    ];
  };

  flake.homeConfigurations.nixd = common.mkHomeManager {
    system = "x86_64-linux";
    username = "austin";
    stateVersion = "25.11";
  };
}
