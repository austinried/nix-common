inputs: system: {
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit system;
  };
  pkgs-unfree = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  pkgs-unfree-unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
}
