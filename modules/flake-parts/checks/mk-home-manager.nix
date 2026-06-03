{ common, ... }:
{
  perSystem =
    { system, ... }:
    let
      mkCheck =
        args@{
          modules ? [ ],
          ...
        }:
        common.mkHomeManager (
          args
          // {
            inherit system;

            username = "austin";

            modules = [
              {
                home.stateVersion = "25.11";
              }
            ]
            ++ modules;
          }
        );
    in
    {
      checks.mkHomeManager-minimal = (mkCheck { }).activationPackage;

      checks.mkHomeManager-full =
        (mkCheck {
          modules = [
            {
              common.developer.enable = true;
              common.japanese.enable = true;
              common.shell.enable = true;
              common.standalone.enable = false;
              common.terminal.enable = true;
              common.vscodium.enable = true;
              common.yadm.enable = true;
            }
          ];
        }).activationPackage;
    };
}
