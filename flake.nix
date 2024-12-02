{
  description = "Mitchell Pleunes Nix flake for mcs5623 workspace";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    poetry2nix.url = "github:nix-community/poetry2nix";
  };

  outputs =
    inputs@{ flake-parts, poetry2nix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];
      perSystem =
        { pkgs, config, ... }:
        let
          inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryEnv defaultPoetryOverrides;
          poetry_overrides = defaultPoetryOverrides.extend (
            self: super: {
              # This modules added from github needs setuptools build-input patch
              # https://github.com/nix-community/poetry2nix/blob/8ffbc64abe7f432882cb5d96941c39103622ae5e/docs/edgecases.md#modulenotfounderror-no-module-named-packagename
              apriori-python = super.apriori-python.overridePythonAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools ];
              });
            }
          );
        in
        {
          apps.default = {
            type = "app";
            program = pkgs.writeShellApplication {
              name = "poetry-defined-jupyter-lab";
              runtimeInputs = [
                (mkPoetryEnv {
                  overrides = poetry_overrides;
                  projectDir = ./.;
                  groups = [ "jupyter" ];
                })
              ];
              text = "jupyter lab";
            };
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              bashInteractive
              (mkPoetryEnv {
                overrides = poetry_overrides;
                projectDir = ./.;
              })
            ];
          };
        };
    };
}
