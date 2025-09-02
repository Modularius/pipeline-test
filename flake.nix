{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    pipeline.url = "github:STFC-ICD-Research-and-Design/supermusr-data-pipeline";
    #pipeline.url = "/home/ubuntu/SuperMuSRDataPipeline?dir=supermusr-data-pipeline";
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
    pipeline
  } : flake-utils.lib.eachDefaultSystem
    ( system:
        let
          pkgs = (import nixpkgs) {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs-unstable = (import nixpkgs-unstable) {
            inherit system;
          };
        in {
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              nil
              nixd
              direnv
              python312
              valgrind-light
              cifs-utils
              nfs-utils
              hdf5_1_10
              kcat
              pkgs-unstable.cargo-leptos
              dart-sass
              podman-compose
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
                h5py
                elasticsearch
              ]
            );
            inputsFrom  = [
              pipeline.devShell.${system}
            ];
          };
        }
    );
}