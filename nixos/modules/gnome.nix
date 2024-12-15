{ pkgs, username, ... }:
{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  networking.networkmanager.enable = true;

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  home-manager.users.${username} =
    {
      lib,
      pkgs,
      pkgs-unfree,
      ...
    }:
    {
      home.packages = with pkgs; [
        eyedropper
        gnome-extension-manager
        papirus-icon-theme

        gnome-tweaks
        gnomeExtensions.appindicator
        gnomeExtensions.emoji-copy
        gnomeExtensions.just-perfection
        gnomeExtensions.wireless-hid
        gnomeExtensions.wifi-qrcode
        gnomeExtensions.vitals
        gnomeExtensions.clipboard-history
      ];

      # https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
      # https://github.com/nix-community/dconf2nix
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
            "wifiqrcode@glerro.pm.me"
            "wireless-hid@chlumskyvaclav.gmail.com"
            "just-perfection-desktop@just-perfection"
            "clipboard-history@alexsaveau.dev"
          ];
        };
        "org/gnome/shell/extensions/just-perfection" = {
          quick-settings-dark-mode = false;
          switcher-popup-delay = false;
        };

        "org/gnome/shell".favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "org.gnome.Console.desktop"
          "firefox.desktop"
          "codium.desktop"
        ];

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
        };
        "org/gnome/shell/app-switcher".current-workspace-only = true;
      };
    };
}
