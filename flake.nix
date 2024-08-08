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
            config.allowUnfree = true;
          };
        in {
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixd
              direnv
              python312
            ] ++ (
              with python312Packages; [
                pip
                requests
                pandas
                matplotlib
                numpy
                scipy
                ipykernel
                ipywidgets
              ]
            );
            inputsFrom  = [
              pipeline.devShell.${system}
            ];
          };
        }
    );
}