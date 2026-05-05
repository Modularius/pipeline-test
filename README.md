# SuperMuSR Data Pipeline Deployment

## Deployment

### Installation

To deploy the pipeline in a system, do the following:
1. Clone the github repo `STFC-ICD-Research-and-Design/supermusr-data-pipeline` and cd into the directory `supermusr-data-pipeline`.
2. Run `nix develop --command cargo build --release`.
3. Clone the github repo `Modularius/pipeline-test` and cd into `pipeline-test`.

## Commands

Upon entering a `nu` shell the following commands are available:

- `run_pipeline <mode> <execution>` : this runs an execution in the context of the given mode.
- `kill <mode>` : this tears down the pipeline and simulator in the context of the given mode.
- `init_settings <broker> <pipeline> <detector>` : this compiles the `compiles.settings.json` files from the `settings.json` file using the given `broker`, `pipeline`, `detector` arguments.

## File Structure

### archive

This is a link to the mounted archive directory.

### Compose

Here is where the podman/docker compose `yml` files live. Files with a `.template` suffix contain environment variable arguments,
which must be substituted in creating corresponding files without the `.template` suffix. It is these resulting files that are used by
podman/docker.

- `pipeline.template.yml`/`pipeline.yml`: these build the pipeline containers.
- `simulator.template.yml`/`simulator.yml`: these build the simulator container.
- `trace-viewer.yml`: this builds the trace-viewer container.
- `redpanda.yml`: this builds the broker container.
- `nginx.yml`: this builds the reverse proxy container used by the trace-viewer.

### executions

Contains `.nu` scripts which define an execution.
An execution is an abstracted sequence of instructions which control the pipeline and simulator.

- `benchmark.nu` : 
- `closures.nu` : 
- `for_anthony.nu` : 
- `reader.nu` : 
- `simulator.nu` : 
- `standard.nu` : 
- `stress_test.nu` : 
- `tests.nu` : 

### nu

Contains most of the `.nu` scripts used to control the pipeline, the following toplevel files exist:

- `diagnostic.nu`
- `init_settings.nu`
- `kill.nu`
- `run_pipeline.nu`
- `viewer.nu`

#### build

Contains most of the files needed to build the `compiled.settings.json` file and others.

- `analysis.nu` : 
- `args.nu` : 
- `detector.nu` : 
- `prelude.nu` : 
- `settings.nu` : 

#### modes

Modes provide a context for the execution layer to control the pipeline and simulator,
namely the `host` and `container` contexts. These correspond to running the pipeline
directly on the host, on within contianers using podman.

- `closures.nu` : 
- `container.nu` : 
- `host.nu` : 

#### param_space

#### tools

Ancillary tools not necessary for the main commands.

### Output

### Simulations

## The `settings.nu` file.

This script consists of several records which define the behaviour of the pipeline, as well as the various options the user wants available.

### The `components` record

This contains settings that are largely consistant across all executions and brokers.
For each component `trace_to_events`, `digitiser_aggregator`, `nexus_writer`, `simulator`, `reader`, and `diagnostics`, the following fields are available:

- `execution_path` : 
- `image_env_vars` : 
- `observability` : 

### The `constants` record

### The `detector_settings` record

These are the settings used by the `trace_to_events` component.

### The `pipeline_settings` record

These are component-level settings that can be selected when calling `init_settings`, as oppose to those found in `components`.

### The `brokers` record

These are settings which define how the pipeline interacts with the broker.

## Setup

1. In file `Settings/PipelineSetup.sh`:

    1. Ensure `APPLICATION_PREFIX` points to the directory containing the component executables.
    2. Ensure `OTEL_ENDPOINT` points to the correct OpenTelemetry connector.

2. Duplicate folders in `Settings/` for each broker you wish to connect to. By default `Settings/Local` is included for if a broker is installed locally. For broker in "location", modify the file `Settings/"location"/PipelineConfig.sh`

    1. Set `BROKER` to point to the kafka broker.
    2. Set `TRACE_TOPIC`, `DAT_EVENT_TOPIC`, etc to the names of the approprate topics on the broker.
    3. Set `DIGITIZERS` to the list of `digitiser_id`s that are handled by the broker (make use of `build_digitiser_argument` if possible).
    4. Set `NEXUS_OUTPUT_PATH` to point to the desired location of the Nexus Writer output. Each broker should have its own folder in `Output`.

3. In the file `Settings/EventFormationConfig.sh` set the [TODO]

## Configuration

Having configured the currently existing shell files the following can be created.

|   |   |
|---|---|
|Docker|Contains `.yaml` and `.env.` files for `docker-compose`|
|Docs|Contains documentation specific to this deployment|
|Jupyter|Python/Jupyter scripts specific to this deployment|
|Scripts|Each file is a shell which runs a specific set of instructions.| 
|Simulations|Contains `.json` files for use by the simulator|
|Tests|Shell files which perform specific tasks, which can be performed by multiple `Scripts/` shells|

## Execution and Exiting

To run call `./run_pipeline.sh`.

To kill the pipeline (though not the simulator) call `./kill.sh`.

To mount the archive, run

```shell
mount -t cifs \
   -o username=SuperMusr_mgr -o password=******** \
   -o domain=ISIS -o vers=2.1 -o noserverino -o _netdev \
   -o uid=****,gid=****,rw,auto,file_mode=0766,dir_mode=0775 \
   //ISISARVR55.isis.cclrc.ac.uk/SuperMusrTestDataBackup$ \
   /mnt/archive
```


altering any parameters as required.
