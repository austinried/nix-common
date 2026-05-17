{
  lib,
  config,
  hostname,
  pkgs,
  ...
}:
let
  cfg = config.common.dotfiles;
in
{
  options.common.dotfiles = {
    enable = lib.mkEnableOption "dotfiles";

    distro = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    common.dconf-mirror = {
      enable = true;
      watches = [
        { prefix = "/com/gexperts/Tilix/"; }
        { prefix = "/org/gnome/settings-daemon/plugins/media-keys/"; }
        { prefix = "/org/gnome/desktop/wm/keybindings/"; }
        { prefix = "/org/gnome/shell/keybindings/"; }
      ];
    };

    common.yadm = {
      enable = true;
      origin = "git@github.com:austinried/dotfiles.git";

      bootstrap = pkgs.writeShellScript "yadm-bootstrap" ''
        echo "symlinking yadm repo to ~/.git"
        ln -sf ${config.xdg.dataHome}/yadm/repo.git ${config.home.homeDirectory}/.git

        if command -v dconf-mirror >/dev/null 2>&1; then
          systemctl --user stop dconf-mirror
          dconf-mirror --once-from file
          systemctl --user start dconf-mirror
        fi
      '';

      repoSettings = {
        local = {
          inherit hostname;
          inherit (cfg) distro;

          distro-family = cfg.distro;
        };

        status.showUntrackedFiles = true;
      };
    };
  };
}
