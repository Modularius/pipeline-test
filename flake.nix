{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    pipeline = "path:../supermusr-data-pipeline";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pipeline
  } : flake-utils.lib.eachDefaultSystem
    ( system:
        let
          pkgs = (import nixpkgs);
        in {
          devShell = pkgs.mkShell {
            inputsFrom  = [
              pipeline.devShell.${system}.devShell
            ];
          };
        }
    );
}