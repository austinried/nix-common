{ pkgs, lib, isWorkstation, stateVersion, ... }:
{
  programs.bash.enable = true;
  programs.starship.enable = true;

  home.packages = with pkgs; [
    
  ]
  ++ lib.optionals isWorkstation [
    eyedropper
    gnome-extension-manager
    papirus-icon-theme
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

    gnome.gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.emoji-copy
    gnomeExtensions.just-perfection
    gnomeExtensions.wireless-hid
    gnomeExtensions.wifi-qrcode
    gnomeExtensions.vitals
    gnomeExtensions.clipboard-history
  ];

  dconf.settings = lib.mkIf isWorkstation (with lib.hm.gvariant; {
    "org/gnome/desktop/interface" = {
      clock-format = "24h";
      clock-show-weekday = true;
      enable-hot-corners = true;
      show-battery-percentage = true;
      enable-animations = true;
      color-scheme = "prefer-dark";
      icon-theme = "Papirus-Dark";
      font-name = "Cantarell 12";
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
    # TODO: just perfection settings
    "org/gnome/shell/extensions/just-perfection" = {};
  });

  home.stateVersion = stateVersion;
}
