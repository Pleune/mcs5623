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
          inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryEnv;
        in
        {
          apps.default = {
            type = "app";
            program = pkgs.writeShellApplication {
              name = "poetry-defined-jupyter-lab";
              runtimeInputs = [
                (mkPoetryEnv {
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
              (mkPoetryEnv { projectDir = ./.; })
            ];
          };
        };
    };
}
