{
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.common.developer;
in
{
  imports = [
    ./android.nix
  ];

  options.common.developer = {
    enable = lib.mkEnableOption "Programs and settings for developers.";
  };

  config = lib.mkIf cfg.enable {
    common.developer.android.enable = lib.mkDefault true;

    home-manager.users.${username} =
      { pkgs, pkgs-unfree, ... }:
      {
        home.packages = with pkgs; [
          nixd
          nil
          nixfmt-rfc-style

          sqlitebrowser
        ];

        programs.git = {
          enable = true;
          extraConfig = {
            init.defaultBranch = "main";
          };
        };

        programs.direnv.enable = true;
        programs.direnv.nix-direnv.enable = true;

        programs.vscode = {
          enable = true;
          package = pkgs.vscodium;

          extensions = with pkgs.vscode-extensions; [
            dracula-theme.theme-dracula
            pkief.material-icon-theme

            pkgs-unfree.vscode-extensions.mhutchie.git-graph
            mkhl.direnv

            jnoortheen.nix-ide
            hashicorp.terraform
            denoland.vscode-deno
            esbenp.prettier-vscode
          ];
          mutableExtensionsDir = true;

          # {
          #   "window.titleBarStyle": "custom",
          #   "files.exclude": {
          #     // "**/node_modules": true,
          #     "**/*.g.dart": true,
          #     "**/*.freezed.dart": true,
          #     "**/*.gr.dart": true
          #   },
          #   "security.workspace.trust.untrustedFiles": "open",
          #   "workbench.iconTheme": "material-icon-theme",
          #   "editor.fontFamily": "'JetBrainsMono Nerd Font','monospace', monospace",
          #   "git.confirmSync": false,
          #   "typescript.updateImportsOnFileMove.enabled": "always",
          #   "explorer.confirmDragAndDrop": false,
          #   "explorer.confirmDelete": false,
          #   "editor.foldingImportsByDefault": false,
          #   "[typescriptreact]": {
          #     "editor.defaultFormatter": "esbenp.prettier-vscode"
          #   },
          #   "files.insertFinalNewline": true,
          #   "editor.rulers": [
          #     120
          #   ],
          #   "javascript.updateImportsOnFileMove.enabled": "always",
          #   "[typescript]": {
          #     "editor.defaultFormatter": "esbenp.prettier-vscode"
          #   },
          #   "git.enableSmartCommit": true,
          #   "[json]": {
          #     "editor.defaultFormatter": "vscode.json-language-features"
          #   },
          #   "editor.tabSize": 2,
          #   "[javascript]": {
          #     "editor.defaultFormatter": "esbenp.prettier-vscode"
          #   },
          #   "debug.openDebug": "openOnDebugBreak",
          #   "[dart]": {
          #     // Automatically format code on save and during typing of certain characters
          #     // (like `;` and `}`).
          #     "editor.formatOnSave": true,
          #     "editor.formatOnType": true,
          #     // Draw a guide line at 80 characters, where Dart's formatting will wrap code.
          #     "editor.rulers": [
          #       80
          #     ],
          #     // Disables built-in highlighting of words that match your selection. Without
          #     // this, all instances of the selected text will be highlighted, interfering
          #     // with Dart's ability to highlight only exact references to the selected variable.
          #     "editor.selectionHighlight": false,
          #     // By default, VS Code prevents code completion from popping open when in
          #     // "snippet mode" (editing placeholders in inserted code). Setting this option
          #     // to `false` stops that and allows completion to open as normal, as if you
          #     // weren't in a snippet placeholder.
          #     "editor.suggest.snippetsPreventQuickSuggestions": false,
          #     // By default, VS Code will pre-select the most recently used item from code
          #     // completion. This is usually not the most relevant item.
          #     //
          #     // "first" will always select top item
          #     // "recentlyUsedByPrefix" will filter the recently used items based on the
          #     //     text immediately preceding where completion was invoked.
          #     "editor.suggestSelection": "first",
          #     // Allows pressing <TAB> to complete snippets such as `for` even when the
          #     // completion list is not visible.
          #     "editor.tabCompletion": "onlySnippets",
          #     // By default, VS Code will populate code completion with words found in the
          #     // current file when a language service does not provide its own completions.
          #     // This results in code completion suggesting words when editing comments and
          #     // strings. This setting will prevent that.
          #     "editor.wordBasedSuggestions": "off",
          #   },
          #   "dart.additionalAnalyzerFileExtensions": [
          #     "drift"
          #   ],
          #   "[jsonc]": {
          #     "editor.defaultFormatter": "vscode.json-language-features"
          #   },
          #   "redhat.telemetry.enabled": false,
          #   "xml.format.splitAttributes": true,
          #   "files.associations": {
          #     "*.yml": "yaml",
          #     "*.arb": "json",
          #     "*.conf": "NGINX",
          #     "*.drift": "sql"
          #   },
          #   "dart.debugExternalPackageLibraries": true,
          #   "dart.debugSdkLibraries": true,
          #   "[html]": {
          #     "editor.defaultFormatter": "vscode.html-language-features"
          #   },
          #   "phpSniffer.autoDetect": true,
          #   "phpSniffer.standard": "PSR2",
          #   "emmet.showAbbreviationSuggestions": false,
          #   "emmet.showExpandedAbbreviation": "never",
          #   "[php]": {
          #     "editor.defaultFormatter": "bmewburn.vscode-intelephense-client"
          #   },
          #   "php.validate.enable": false,
          #   "php.suggest.basic": false,
          #   "errorLens.messageTemplate": "($count) $message",
          #   "errorLens.scrollbarHackEnabled": true,
          #   "errorLens.followCursor": "allLinesExceptActive",
          #   "errorLens.gutterIconsEnabled": true,
          #   "errorLens.gutterIconSet": "defaultOutline",
          #   "errorLens.gutterIconSize": "auto",
          #   "errorLens.margin": "2ch",
          #   "errorLens.fontStyleItalic": true,
          #   "errorLens.messageBackgroundMode": "message",
          #   "psalm.psalmVersion": "",
          #   "psalm.psalmScriptPath": "",
          #   "[yaml]": {
          #     "editor.defaultFormatter": "redhat.vscode-yaml"
          #   },
          #   "editor.codeActionsOnSave": {
          #     "source.organizeImports": "explicit"
          #   },
          #   "git.openRepositoryInParentFolders": "never",
          #   "sqltools.highlightQuery": false,
          #   "[sql]": {
          #     "editor.defaultFormatter": "mtxr.sqltools"
          #   },
          #   "editor.tokenColorCustomizations": {
          #     "textMateRules": [
          #       {
          #         "scope": "variable.other.constant",
          #         "settings": {
          #           "foreground": "#f5f5f5"
          #         }
          #       }
          #     ]
          #   },
          #   // "prettier.arrowParens": "avoid",
          #   // "prettier.printWidth": 120,
          #   "prettier.semi": false,
          #   "go.toolsManagement.autoUpdate": true,
          #   "[vue]": {
          #     "editor.defaultFormatter": "esbenp.prettier-vscode"
          #   },
          #   "editor.formatOnSave": true,
          #   "rust-analyzer.inlayHints.chainingHints.enable": false,
          #   "cSpell.userWords": [
          #     "iframes",
          #     "Laravel",
          #     "Meilisearch",
          #     "Riedhammer"
          #   ],
          #   "editor.minimap.enabled": false,
          #   "rubyLsp.enableExperimentalFeatures": false,
          #   "omnisharp.dotNetCliPaths": [
          #     "/usr/bin/dotnet"
          #   ],
          #   "omnisharp.sdkPath": "/usr/share/dotnet/sdk/6.0.413",
          #   "window.zoomLevel": 1,
          #   "eslint.experimental.useFlatConfig": true,
          #   "sqltools.useNodeRuntime": true,
          #   "nix.enableLanguageServer": true,
          #   "workbench.colorTheme": "Dracula Theme",
          # }

          # userSettings = {
          #   "workbench.iconTheme" = "material-icon-theme";
          #   "editor.fontFamily" = "'JetBrainsMono Nerd Font','monospace', monospace";
          #   "workbench.colorTheme" = "Dracula Theme";
          # };
        };
      };
  };
}
