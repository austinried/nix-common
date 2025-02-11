{
  lib,
  config,
  ...
}:
let
  cfg = config.common.firefox;
in
{
  options.common.firefox = {
    enable = lib.mkEnableOption "Install the Firefox web browser.";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DontCheckDefaultBrowser = true;
        DisablePocket = true;
        SearchBar = "unified";

        Preferences =
          let
            lock-false = {
              Value = false;
              Status = "locked";
            };
            # lock-true = {
            #   Value = true;
            #   Status = "locked";
            # };
            lock-empty-string = {
              Value = "";
              Status = "locked";
            };
          in
          {
            # Privacy settings
            "extensions.pocket.enabled" = lock-false;
            "browser.newtabpage.pinned" = lock-empty-string;
            "browser.topsites.contile.enabled" = lock-false;
            "browser.newtabpage.activity-stream.showSponsored" = lock-false;
            "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
          };

        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
          };
          "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/traduzir-paginas-web/latest.xpi";
            installation_mode = "force_installed";
          };
          "jid1-5Fs7iTLscUaZBgwr@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/happy-bonobo-disable-webrtc/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };

      profiles.default = {
        settings = {
          "signon.rememberSignons" = false;
          "widget.use-xdg-desktop-portal.file-picker" = 1;
          "browser.aboutConfig.showWarning" = false;

          "apz.overscroll.enabled" = false;
        };

        search = {
          force = true;
          default = "DuckDuckGo";
          order = [
            "DuckDuckGo"
            "Google"
          ];
        };
      };
    };
  };
}
