{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.common.terminal;
in
{
  options.common.terminal = {
    enable = lib.mkEnableOption "Enable terminal configuration.";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

    fonts.fontconfig.enable = true;

    programs.ghostty = {
      enable = true;
      enableBashIntegration = true;

      settings = {
        theme = "Dracula+";
        window-theme = "ghostty";
        window-padding-x = 4;
        window-padding-color = "extend";
        gtk-titlebar = false;
        # gtk-titlebar-hide-when-maximized = true;
        adw-toolbar-style = "flat";
      };
    };

    programs.ssh = {
      enable = true;

      # fix for ghostty, otherwise backspace and other things break on some hosts
      # https://ghostty.org/docs/help/terminfo#configure-ssh-to-fall-back-to-a-known-terminfo-entry
      extraConfig = ''
        Host *
          SetEnv TERM=xterm-256color
      '';
    };
  };
}
