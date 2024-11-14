. ./Settings/PipelineSetup.sh
. ./Libs/lib.sh
. ./Libs/lib_pipeline.sh

kill_persistant_components

$g_CONTAINER_ENGINE stop --all