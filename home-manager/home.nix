{ pkgs, stateVersion, ... }:
{
  programs.bash.enable = true;
  programs.starship.enable = true;

  home.stateVersion = stateVersion;
}
