# https://wiki.nixos.org/wiki/Android
{
  lib,
  config,
  pkgs,
  username,
  ...
}:
let
  cfg = config.common.developer.android;
in
{
  options.common.developer.android = {
    enable = lib.mkEnableOption "Android development tools.";
  };

  config = lib.mkIf cfg.enable {
    users.users.${username}.extraGroups = [
      "kvm"
      "adbusers"
    ];

    virtualisation.waydroid.enable = true;

    environment.systemPackages = with pkgs; [
      # enables clipboard sharing under wayland for waydroid
      wl-clipboard
    ];

    programs.adb.enable = true;
  };
}
