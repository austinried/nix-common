{
  lib,
  username,
  pkgs,
  ...
}:
{
  imports = [
    ./dconf-mirror.nix
    ./developer.nix
    ./dotfiles.nix
    ./shell.nix
    ./standalone.nix
    ./vscodium.nix
    ./terminal.nix
    ./japanese.nix
    ./yadm.nix
  ];

  home = {
    inherit username;

    homeDirectory = lib.mkDefault (
      if pkgs.stdenv.isLinux then
        "/home/${username}"
      else if pkgs.stdenv.isDarwin then
        "/Users/${username}"
      else
        null
    );
  };
}
