{ ... }:
{
  programs.firefox = {
    enable = true;

    profiles.default = {
      settings = {
        "browser.search.defaultenginename" = "DuckDuckGo";
        "browser.search.order.1" = "DuckDuckGo";

        "signon.rememberSignons" = false;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "browser.aboutConfig.showWarning" = false;
        "browser.compactmode.show" = true;

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
}
