{
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    git
    jq

    curl
    wget

    pciutils
    inetutils
    usbutils
    lsof

    wireguard-tools
  ];

  programs = {
    nano.enable = lib.mkDefault false;
  };

  services = {
    openssh.enable = true;
  };
}
