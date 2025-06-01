{
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.common.gnome;
in
{
  options.common.gnome = {
    enable = lib.mkEnableOption "Enable the Gnome desktop environment.";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    services.automatic-timezoned.enable = true;

    networking.networkmanager.enable = true;

    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    home-manager.users.${username} =
      { lib, pkgs, ... }:
      {
        home.packages = with pkgs; [
          papirus-icon-theme

          nerd-fonts.jetbrains-mono

          gnome-tweaks
          gnome-extension-manager
          gnomeExtensions.appindicator
          gnomeExtensions.emoji-copy
          gnomeExtensions.just-perfection
          gnomeExtensions.wireless-hid
          gnomeExtensions.vitals
          gnomeExtensions.clipboard-history

          ungoogled-chromium
          google-chrome
          thunderbird-latest

          vlc
          impression
        ];

        fonts.fontconfig.enable = true;

        # https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
        # https://github.com/nix-community/dconf2nix
        # https://nix-community.github.io/home-manager/index.xhtml#sec-option-types
        dconf.settings = with lib.hm.gvariant; {
          "org/gnome/desktop/interface" = {
            clock-format = "24h";
            clock-show-weekday = true;
            enable-hot-corners = true;
            show-battery-percentage = true;
            enable-animations = true;
            color-scheme = "prefer-dark";
            icon-theme = "Papirus-Dark";
            font-name = "Cantarell 11";
            document-font-name = "Cantarell 12";
            monospace-font-name = "JetBrainsMonoNL Nerd Font Mono 11";
            font-antialiasing = "rgba";
            font-hinting = "slight";
          };
          "org/gnome/desktop/wm/preferences" = {
            button-layout = "appmenu:minimize,maximize,close";
          };
          "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions = [
              "appindicatorsupport@rgcjonas.gmail.com"
              "drive-menu@gnome-shell-extensions.gcampax.github.com"
              "user-theme@gnome-shell-extensions.gcampax.github.com"
              "wireless-hid@chlumskyvaclav.gmail.com"
              "just-perfection-desktop@just-perfection"
              "clipboard-history@alexsaveau.dev"
            ];
          };
          "org/gnome/shell/extensions/just-perfection" = {
            quick-settings-dark-mode = false;
            switcher-popup-delay = false;
          };

          "org/gnome/desktop/wm/keybindings" = {
            # Alt+Tab windows not grouped applications
            switch-applications = [ ];
            switch-applications-backward = [ ];
            switch-windows = [ "<Alt>Tab" ];
            switch-windows-backwards = [ "<Shift><Alt>Tab" ];
          };

          # Rebind Super+v so it can be used for history paste
          "org/gnome/desktop/wm/keybindings".toggle-message-tray = [ ];
          "org/gnome/shell/extensions/clipboard-history".toggle-menu = [ "<Super>v" ];

          "org/gnome/settings-daemon/plugins/media-keys".home = [ "<Super>e" ];

          "org/gnome/mutter" = {
            edge-tiling = true;
            dynamic-workspaces = true;

            # Prevents "X is not responding" prompts
            check-alive-timeout = mkUint32 0;
          };
          "org/gnome/shell/app-switcher".current-workspace-only = true;
        };
      };
  };
}
