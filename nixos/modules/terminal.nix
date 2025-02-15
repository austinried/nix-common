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
          #
          # tilix
          #
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

          #
          # blackbox
          #
          "com/raggesilver/BlackBox" = {
            font = "JetBrainsMonoNL Nerd Font Mono 11";
            theme-dark = "Dracula";
            style-preference = mkUint32 2;
            terminal-bell = false;
            terminal-padding = mkTuple [
              (mkUint32 4)
              (mkUint32 4)
              (mkUint32 4)
              (mkUint32 4)
            ];
          };
        };
      };
  };
}
