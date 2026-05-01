{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.common.shell;
in
{
  options.common.shell = {
    enable = lib.mkEnableOption "Shell utilities, settings, and scripts. Mostly for bash.";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      tlrc
    ];

    home.sessionVariables = {
      EDITOR = "micro";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };

    programs.micro.enable = true;
    programs.bat.enable = true;
    programs.btop.enable = true;

    programs.bash = {
      enable = true;
      enableVteIntegration = true;

      package = lib.mkIf config.common.standalone.enable null;

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

      shellAliases = {
        ls = "ls --color";
        ll = "ls -lhF";
      };

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

        # Keep Ctrl-Left and Ctrl-Right working when the above are used
        bind '"\e[1;5C":forward-word'
        bind '"\e[1;5D":backward-word'
      '';
    };

    programs.starship = {
      enable = true;
      settings = {
        nix_shell = {
          format = "via [$symbol$name]($style) ";
          symbol = "❄️ ";
        };

        gcloud.disabled = true;
        terraform.disabled = true;
      };
    };

    programs.atuin = {
      enable = true;
      # https://docs.atuin.sh/configuration/config/
      settings = {
        style = "compact";
        inline_height = 12;
        search_mode_shell_up_key_binding = "prefix";
        filter_mode_shell_up_key_binding = "session";
        enter_accept = true;
      };
    };
  };
}
