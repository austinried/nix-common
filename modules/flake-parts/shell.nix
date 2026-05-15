{
  perSystem =
    { pkgs, config, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "nix-common";

        inputsFrom = [ config.packages.dconf-mirror ];

        packages = with pkgs; [
          yq-go
        ];
      };
    };
}
