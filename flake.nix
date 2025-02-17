{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    pipeline.url = "github:STFC-ICD-Research-and-Design/supermusr-data-pipeline";
    #pipeline.url = "/home/ubuntu/SuperMuSRDataPipeline?dir=supermusr-data-pipeline";
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
              nil
              nixd
              direnv
              python312
              valgrind-light
              cifs-utils
              nfs-utils
              hdf5_1_10
              kcat
              podman-compose
              netdata
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