{
  description = "A core's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        {
          pkgs,
          lib,
          ...
        }:
        let
          aizawa-yasunori = pkgs.python3Packages.buildPythonApplication {
            pname = "aizawa-yasunori";
            version = "0.1.0";
            pyproject = true;
            src = lib.cleanSource ./.;

            build-system = [
              pkgs.python3Packages.setuptools
            ];
          };
        in
        {
          treefmt = {
            projectRootFile = "flake.nix";

            # Nix
            programs.nixfmt.enable = true;

            # Python
            programs.ruff-check.enable = true;
            programs.ruff-format.enable = true;
          };

          packages = {
            inherit aizawa-yasunori;
            default = aizawa-yasunori;
          };

          devShells.default = pkgs.mkShell {
            packages = [
              # Rust
              pkgs.python3

              # Nix
              pkgs.nil
            ];

            shellHook = ''
              export PS1="\n[nix-shell:\w]$ "
            '';
          };
        };
    };
}
