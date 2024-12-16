{
  lib,
  config,
  pkgs,
  username,
  ...
}:
let
  module = "japanese";
  cfg = config.common.${module};
in
{
  options.common.${module}.enable =
    lib.mkEnableOption "Enable Japanese input via ibus and mozc (for Gnome).";

  config = lib.mkIf cfg.enable {
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];

    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ mozc ];
    };

    environment.variables = {
      MOZC_IBUS_CANDIDATE_WINDOW = "ibus";
      GTK_IM_MODULE = "ibus";
    };

    home-manager.users.${username} =
      { lib, ... }:
      {
        dconf.settings = with lib.hm.gvariant; {
          "org/gnome/desktop/input-sources".sources = [
            (mkTuple [
              "xkb"
              "us"
            ])
            (mkTuple [
              "ibus"
              "mozc-jp"
            ])
          ];
        };

        # Keyboard shortcuts to enable toggling kana input mode.
        # These can be imported from a TSV file but it doesn't look like they can be set
        # to read from any config file (`mozc/keymap.tsv` is only a reference of the current map).
        #
        # DirectInput	Ctrl Space	InputModeSwitchKanaType
        # Precomposition	Ctrl Space	InputModeSwitchKanaType
        # Composition	Ctrl Space	InputModeSwitchKanaType

        xdg.configFile."mozc/ibus_config.textproto".text = ''
          # `ibus write-cache; ibus restart` might be necessary to apply changes.
          engines {
            name : "mozc-jp"
            longname : "Mozc"
            layout : "default"
            layout_variant : ""
            layout_option : ""
            rank : 80
            symbol : "あ"
            # Sets the default mode to hiragana on activation
            composition_mode : HIRAGANA
          }
          engines {
            name : "mozc-on"
            longname : "Mozc:あ"
            layout : "default"
            layout_variant : ""
            layout_option : ""
            rank : 99
            symbol : "あ"
            composition_mode : HIRAGANA
          }
          engines {
            name : "mozc-off"
            longname : "Mozc:A_"
            layout : "default"
            layout_variant : ""
            layout_option : ""
            rank : 99
            symbol : "A"
            composition_mode : DIRECT
          }
          active_on_launch: False
          mozc_renderer {
            # Set 'False' to use IBus' candidate window.
            enabled : True
            # For Wayland sessions, 'mozc_renderer' will be used if and only if any value
            # set in this field (e.g. "GNOME", "KDE") is found in $XDG_CURRENT_DESKTOP.
            # https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#recognized-keys
            compatible_wayland_desktop_names : ["GNOME"]
          }
        '';
      };
  };
}
