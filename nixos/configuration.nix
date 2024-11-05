{ pkgs, username, hostname, stateVersion, ... }: 
{
  networking.hostName = hostname;

  users.users.${username} = {
    isNormalUser = true;
  };

  environment.systemPackages = with pkgs; [
    micro
  ];

  system.stateVersion = stateVersion;
}
