{ common, ... }:
{
  perSystem =
    { system, ... }:
    let
      baseArgs = {
        inherit system;
        username = "austin";
        stateVersion = "25.11";
      };
    in
    {
      checks.mkHomeManager-minimal = (common.mkHomeManager baseArgs).activationPackage;

      checks.mkHomeManager-full =
        (common.mkHomeManager (
          baseArgs
          // {
            modules = [
              {
                common.developer.enable = true;
                common.japanese.enable = true;
                common.shell.enable = true;
                common.standalone.enable = false;
                common.terminal.enable = true;
                common.vscode.enable = true;
                common.yadm.enable = true;
              }
            ];
          }
        )).activationPackage;
    };
}
