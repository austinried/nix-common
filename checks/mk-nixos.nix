{ common, ... }:
{
  perSystem =
    { ... }:
    let
      minimalNixosConfig = {
        boot.loader.systemd-boot.enable = true;

        fileSystems."/" = {
          device = "/dev/sda1";
          fsType = "ext4";
        };
      };
    in
    {
      checks.mkNixos-minimal =
        (common.mkNixos {
          system = "x86_64-linux";
          hostname = "test";

          modules = [ minimalNixosConfig ];

          stateVersion = "25.11";
        }).config.system.build.toplevel;

      checks.mkNixos-full =
        (common.mkNixos {
          system = "x86_64-linux";
          hostname = "test";

          modules = [
            minimalNixosConfig
            {
              common.developer.enable = true;

              common.nixos-hm.android.enable = true;
              common.nixos-hm.firefox.enable = true;
              common.nixos-hm.gnome.enable = true;
              common.nixos-hm.japanese.enable = true;
              common.nixos-hm.terminal.enable = true;
              common.nixos-hm.vscode.enable = true;
            }
          ];

          users = [
            {
              username = "austin";
              modules = [
                {
                  # TODO: refactor these, they conflict with nixos-hm modules and should
                  # only set non-gui stuff that would be safe on non-nixos systems
                  # common.developer.enable = true;
                  # common.japanese.enable = true;
                  # common.shell.enable = true;
                  # common.standalone.enable = false;
                  # common.terminal.enable = true;
                  # common.vscode.enable = true;
                }
              ];
            }
          ];

          stateVersion = "25.11";
        }).config.system.build.toplevel;
    };
}
