{ common, ... }:
{
  perSystem =
    { system, ... }:
    let
      mkCheck =
        args@{
          modules ? [ ],
          ...
        }:
        common.mkNixos (
          args
          // {
            inherit system;
            hostname = "test";

            modules = [
              {
                boot.loader.systemd-boot.enable = true;
                fileSystems."/".device = "/dev/sda1";
                fileSystems."/".fsType = "ext4";

                system.stateVersion = "25.11";
              }
            ]
            ++ modules;
          }
        );
    in
    {
      checks.mkNixos-minimal = (mkCheck { }).config.system.build.toplevel;

      checks.mkNixos-full =
        (mkCheck {
          modules = [
            {
              common.developer.enable = true;

              common.nixos-hm.android.enable = true;
              common.nixos-hm.firefox.enable = true;
              common.nixos-hm.gnome.enable = true;
              common.nixos-hm.japanese.enable = true;
              common.nixos-hm.terminal.enable = true;
              common.nixos-hm.vscodium.enable = true;
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
                  common.shell.enable = true;
                  # common.standalone.enable = false;
                  # common.terminal.enable = true;
                  # common.vscodium.enable = true;
                  common.yadm.enable = true;

                  home.stateVersion = "25.11";
                }
              ];
            }
          ];
        }).config.system.build.toplevel;
    };
}
