{ pkgs, lib, isWorkstation, stateVersion, ... }:
{
  imports = [ ./modules ];

  programs.starship.enable = true;
  programs.bash = {
    enable = true;
    enableVteIntegration = true;

    shellOptions = [
      "autocd" # change directory without entering the 'cd' command
      "cdspell" # automatically fix directory typos when changing directory
      "dirspell" # automatically fix directory typos when completing
      "globstar" # ** recursive glob
      # "histappend" # append to history, don't overwrite
      # "histverify" # expand, but don't automatically execute, history expansions
      "nocaseglob" # case-insensitive globbing
      "no_empty_cmd_completion" # do not TAB expand empty lines
      # check the window size after each command and, if necessary,
      # update the values of LINES and COLUMNS.
      "checkwinsize"
    ];

    # historyIgnore = [ "?" ];
    # historyControl = [
    #   "erasedups"
    #   "ignoredups"
    #   "ignorespace"
    # ];

    # initExtra = ''
    #   # If there are multiple matches for completion, Tab should cycle through them
    #   bind 'TAB:menu-complete'
    #   # And Shift-Tab should cycle backwards
    #   bind '"\e[Z": menu-complete-backward'

    #   # Display a list of the matching files
    #   bind "set show-all-if-ambiguous on"

    #   # Perform partial (common) completion on the first Tab press, only start
    #   # cycling full results on the second Tab press (from bash version 5)
    #   bind "set menu-complete-display-prefix on"

    #   # Cycle through history based on characters already typed on the line
    #   bind '"\e[A":history-search-backward'
    #   bind '"\e[B":history-search-forward'

    #   # Keep Ctrl-Left and Ctrl-Right working when the above are used
    #   bind '"\e[1;5C":forward-word'
    #   bind '"\e[1;5D":backward-word'
    # '';
  };

  programs.atuin = {
    enable = true;
    # https://docs.atuin.sh/configuration/config/
    settings = {
      style = "compact";
      filter_mode_shell_up_key_binding = "session";
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages = with pkgs; []
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

  # https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
  # https://github.com/nix-community/dconf2nix
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
