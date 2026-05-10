top@{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.common.yadm;

  gitIni = pkgs.formats.gitIni { listsAsDuplicateKeys = true; };
in
{
  options.common.yadm = {
    enable = lib.mkEnableOption "yadm";

    package = lib.mkPackageOption pkgs "yadm" { };

    origin = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        The primary remote repository URL for yadm to use.
        If set, the repo will be cloned from this URL when the module is first enabled. Otherwise a new repo will be initialized.

        If you wish to set multiple URLs for origin, set repoSettings."remote \"origin\"".url to a list of URLs.
      '';
    };

    settings = lib.mkOption {
      type = gitIni.type;
      default = { };
      description = ''
        Configuration settings for yadm.

        See the Configuration section of the manual:
        https://github.com/yadm-dev/yadm/blob/${pkgs.yadm.version}/yadm.md#configuration
      '';
    };

    repoSettings = lib.mkOption {
      description = ''
        Git config settings for the local yadm repo.

        core.worktree defaults to config.home.homeDirectory.
        "remote \"origin\"".url defaults to cfg.origin.
      '';
      default = { };
      type =
        let
          mkDefault = default: lib.mkOption { inherit default; };
        in
        with lib.types;
        submodule {
          freeformType = gitIni.type;

          options.core = {
            repositoryformatversion = mkDefault 0;
            filemode = mkDefault true;
            bare = mkDefault false;
            sharedrepository = mkDefault "0600";
          };

          options.receive = {
            denyNonFastforwards = mkDefault true;
          };

          options.status = {
            showUntrackedFiles = mkDefault "no";
          };

          options.yadm = {
            managed = mkDefault true;
          };

          options."remote \"origin\"" = {
            fetch = mkDefault "+refs/heads/*:refs/remotes/origin/*";
          };

          options."branch \"main\"" = {
            remote = mkDefault "origin";
            merge = mkDefault "refs/heads/main";
          };

          options.local = lib.mkOption {
            default = { };
            description = ''
              Local configuration settings for yadm, all settings are optional.

              user, os, and arch are automatically set on all systems but can be overridden here.
              hostname, distro, and distro-family are set on NixOS but must be manually set here on other systems.

              See the "local" part of the Configuration section in the manual:
              https://github.com/yadm-dev/yadm/blob/${pkgs.yadm.version}/yadm.md#configuration

              See the Alternates section for information on how the matching values are gathered by yadm:
              https://github.com/yadm-dev/yadm/blob/${pkgs.yadm.version}/yadm.md#alternates
            '';
            type =
              with lib.types;
              submodule {
                options =
                  let
                    localStrOption = lib.mkOption {
                      type = nullOr str;
                      default = null;
                    };
                  in
                  {
                    class = lib.mkOption {
                      type = listOf str;
                      default = [ ];
                    };

                    user = localStrOption;
                    hostname = localStrOption;
                    arch = localStrOption;
                    os = localStrOption;
                    distro = localStrOption;
                    distro-family = localStrOption;
                  };
              };
          };
        };
    };

  };

  config =
    let
      removeNullAttrs = lib.filterAttrs (_: v: v != null && v != [ ]);

      isNixos = top ? osConfig;
      optionalNixos = value: if isNixos then value else null;

      local =
        removeNullAttrs {
          user = config.home.username;
          os = pkgs.stdenv.hostPlatform.uname.system;
          arch = pkgs.stdenv.hostPlatform.uname.processor;

          hostname = optionalNixos top.osConfig.networking.hostName;
          distro = optionalNixos "nixos";
          distro-family = optionalNixos "nixos";
        }
        // removeNullAttrs cfg.repoSettings.local;

      repoSettingsDefaults = {
        core = {
          worktree = config.home.homeDirectory;
        };
      }
      // (
        if cfg.origin != null then
          {
            "remote \"origin\"" = {
              url = cfg.origin;
            };
          }
        else
          { }
      );

      repoConfig = gitIni.generate "repo-config" (
        lib.recursiveUpdate repoSettingsDefaults (lib.recursiveUpdate cfg.repoSettings { inherit local; })
      );
    in
    lib.mkIf cfg.enable {
      home.packages = [ cfg.package ];

      xdg.configFile."yadm/config".source = gitIni.generate "yadm-config" cfg.settings;
      xdg.dataFile."yadm/repo.git/config".source = repoConfig;

      home.activation.yadm =
        let
          inherit (config.home) homeDirectory;

          yadm = "${cfg.package}/bin/yadm";
          repo = "${config.xdg.dataHome}/yadm/repo.git";

          origin = if cfg.origin != null then cfg.origin else "";
        in
        lib.hm.dag.entryAfter [ "writeBoundary" "reloadSystemd" ] ''
          if "${yadm}" rev-parse --git-dir >/dev/null 2>&1; then
            exit 0
          fi

          # move repo config out of the way so clone/init works, move back after
          mv "${repo}/config" /tmp/yadm-repo-config

          if [ -n "${origin}" ]; then
            # system ssh config may break nix git/ssh, so use only the user config
            echo "Include \"${homeDirectory}/.ssh/config\"" > /tmp/ssh-config
            export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -F /tmp/ssh-config"

            run "${yadm}" clone -f "${origin}"
          else
            run "${yadm}" init -f
          fi

          mv /tmp/yadm-repo-config "${repo}/config"
        '';
    };
}
