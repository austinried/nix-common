{
  lib,
  config,
  username,
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
    home-manager.users.${username} =
      { lib, pkgs, ... }:
      {

        home.packages = with pkgs; [
          tilix
          blackbox-terminal

          (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];

        fonts.fontconfig.enable = true;

        dconf.settings = with lib.hm.gvariant; {
          "com/gexperts/Tilix" = {
            prompt-on-close = true;
            sidebar-on-right = false;
            tab-position = "top";
            terminal-title-show-when-single = true;
            terminal-title-style = "small";
            theme-variant = "system";
            use-tabs = true;
            window-style = "borderless";
          };

          "com/gexperts/Tilix/profiles" = {
            default = "2b7c4080-0ddd-46c5-8f23-563fd3ba789d";
            list = [ "2b7c4080-0ddd-46c5-8f23-563fd3ba789d" ];
          };

          "com/gexperts/Tilix/profiles/2b7c4080-0ddd-46c5-8f23-563fd3ba789d" = {
            visible-name = "Default";
            font = "JetBrainsMonoNL Nerd Font Mono 11";
            use-system-font = false;
            terminal-title = "\${id}: \${title}";
          };
        };

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
  };
}
