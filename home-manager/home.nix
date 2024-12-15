{
  pkgs,
  pkgs-unfree,
  lib,
  isWorkstation,
  stateVersion,
  ...
}:
{
  imports = [ ./modules ];

  programs.starship = {
    enable = true;
    settings = {
      nix_shell = {
        format = "via [$symbol$name]($style) ";
        symbol = "❄️ ";
      };
    };
  };

  programs.bash = {
    enable = true;
    enableVteIntegration = true;

    shellOptions = [
      "autocd" # change directory without entering the 'cd' command
      "cdspell" # automatically fix directory typos when changing directory
      "dirspell" # automatically fix directory typos when completing
      "globstar" # ** recursive glob
      # "histappend" # append to history, don't overwrite
      # "histverify" # expand, but don't automatically execute, history expansions
      "nocaseglob" # case-insensitive globbing
      "no_empty_cmd_completion" # do not TAB expand empty lines
      # check the window size after each command and, if necessary,
      # update the values of LINES and COLUMNS.
      "checkwinsize"
    ];

    # historyIgnore = [ "?" ];
    # historyControl = [
    #   "erasedups"
    #   "ignoredups"
    #   "ignorespace"
    # ];

    initExtra = ''
      # If there are multiple matches for completion, Tab should cycle through them
      bind 'TAB:menu-complete'
      # And Shift-Tab should cycle backwards
      bind '"\e[Z": menu-complete-backward'

      # Display a list of the matching files
      bind "set show-all-if-ambiguous on"

      # Perform partial (common) completion on the first Tab press, only start
      # cycling full results on the second Tab press (from bash version 5)
      bind "set menu-complete-display-prefix on"

      # Cycle through history based on characters already typed on the line
      # bind '"\e[A":history-search-backward'
      # bind '"\e[B":history-search-forward'

      # Keep Ctrl-Left and Ctrl-Right working when the above are used
      bind '"\e[1;5C":forward-word'
      bind '"\e[1;5D":backward-word'
    '';
  };

  programs.atuin = {
    enable = true;
    # https://docs.atuin.sh/configuration/config/
    settings = {
      style = "compact";
      inline_height = 12;
      filter_mode_shell_up_key_binding = "session";
      enter_accept = true;
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages =
    with pkgs;
    [ ]
    ++ lib.optionals isWorkstation [
      clapper

      pkgs-unfree.discord

      nixd
      nil
      nixfmt-rfc-style
    ];

  home.stateVersion = stateVersion;
}
