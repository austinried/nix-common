{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.common.dconf-mirror;
in
{
  options.common.dconf-mirror = {
    enable = lib.mkEnableOption "dconf mirror daemon";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../packages/dconf-mirror { };
      description = "The dconf-mirror package to use.";
    };

    syncDir = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "/home/user/.config/dconf-mirror";
      description = ''
        Directory to resolve relative watch file paths against (--sync-dir).
        Defaults to the parent directory of the config file.
      '';
    };

    watches = lib.mkOption {
      description = "dconf subtrees to mirror to files.";
      default = [ ];
      type =
        with lib.types;
        listOf (submodule {
          options = {
            prefix = lib.mkOption {
              type = str;
              example = "/org/gnome/";
              description = "dconf path prefix to watch. Must start and end with '/'.";
            };

            file = lib.mkOption {
              type = nullOr str;
              default = null;
              example = "gnome.dconf";
              description = ''
                Path to the mirror file. Relative paths are resolved against syncDir.
                If null, derived from prefix as <syncDir>/<prefix-parts>.ini.
              '';
            };

            prefer = lib.mkOption {
              type = nullOr (enum [
                "dconf"
                "file"
              ]);
              default = null;
              description = ''
                Which source wins on startup.
                "dconf" writes the current dconf state to the file.
                "file" loads the file into dconf (falls back to dconf -> file if file does not exist).
              '';
            };
          };
        });
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."dconf-mirror/config.json".text = builtins.toJSON {
      watches = map (
        watch:
        lib.filterAttrs (_: v: v != null) {
          inherit (watch) prefix file prefer;
        }
      ) cfg.watches;
    };

    home.packages = [ cfg.package ];

    systemd.user.services.dconf-mirror = {
      Unit = {
        Description = "dconf mirror daemon";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = lib.concatStringsSep " " (
          [
            "${cfg.package}/bin/dconf-mirror"
            "--config"
            "${config.xdg.configHome}/dconf-mirror/config.json"
          ]
          ++ lib.optionals (cfg.syncDir != null) [
            "--sync-dir"
            cfg.syncDir
          ]
        );
        Restart = "on-failure";
        RestartSec = "5s";

      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
