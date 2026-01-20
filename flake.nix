{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
              elvish
              direnv
              python312
              valgrind-light
              cifs-utils
              nfs-utils
              hdf5_1_10
              kcat
              cargo-leptos
              dart-sass
              podman-compose
              cargo
              nushell
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
              pipeline.devShells.${system}
            ];
            shellHook =
              ''
                echo "Hello shell"
                export PATH=/home/ubuntu/.cargo/bin:$PATH
                alias pipeline_run='hush hush/commands.hsh pipeline_run'
                alias pipeline_kill='hush hush/commands.hsh kill'
              '';
            
          };
        }
    );
}