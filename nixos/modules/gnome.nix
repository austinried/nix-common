{
  lib,
  config,
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

    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
