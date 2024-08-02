{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    pipeline.url = "github:STFC-ICD-Research-and-Design/supermusr-data-pipeline";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pipeline
  } : flake-utils.lib.eachDefaultSystem
    ( system:
        let
          pkgs = (import nixpkgs) {
            inherit system;
          };
        in {
          devShell = pkgs.mkShell {
            buildInputs = [
              pkgs.python312
              pkgs.python312.pip
              pkgs.python312.pandas
              pkgs.python312Packages.matplotlib
              pkgs.python312.numpy
              pkgs.python312.ipywidgets
              pkgs.python312Packages.conda
              ];
            inputsFrom  = [
              pipeline.devShell.${system}
            ];
          };
        }
    );
}