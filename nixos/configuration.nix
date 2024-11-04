{ pkgs, username, stateVersion, ... }: 
{
  users.users.${username} = {
    isNormalUser = true;
  };

  environment.systemPackages = with pkgs; [
    micro
  ];

  system.stateVersion = stateVersion;
}
