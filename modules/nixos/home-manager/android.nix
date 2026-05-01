# https://wiki.nixos.org/wiki/Android
args@{ pkgs, ... }:
import ./mk-module args "android" {
  config =
    { cfg, perUser, ... }:
    {
      users.users = perUser {
        extraGroups = [
          "kvm"
          "adbusers"
        ];
      };

      virtualisation.waydroid.enable = true;

      environment.systemPackages = with pkgs; [
        sqlitebrowser

        # enables clipboard sharing under wayland for waydroid
        wl-clipboard
      ];

      programs.adb.enable = true;
    };
}
