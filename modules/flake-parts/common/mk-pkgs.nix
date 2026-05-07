inputs: system:
{
  pkgs-unfree = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
}
// (
  if inputs ? nixpkgs-unstable then
    {
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
      };
      pkgs-unfree-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    }
  else if inputs ? nixpkgs-stable then
    {
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
      };
      pkgs-unfree-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
    }
  else
    { }
)
