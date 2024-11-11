{ pkgs, username, hostname, stateVersion, ... }: 
{
  networking.hostName = hostname;

  users.users.${username} = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    micro
  ];

  system.stateVersion = stateVersion;
}
