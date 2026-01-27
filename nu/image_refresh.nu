const pipeline_dir = "digital-muon-pipeline"
const this_dir = "pipeline-test"

def switch_dir [func: closure] {
    cd $"../($pipeline_dir)"
    do $func
    cd $"../($this_dir)"
}

export def 'main trace_viewer' [] {
    switch_dir { buildah bud -f trace-viewer/Containerfile -t supermusr-trace-viewer:latest --layers=true }
}

export def 'main trace_to_events' [] {
    switch_dir { buildah bud -f Containerfile --build-arg component=trace-to-events -t supermusr-trace-to-events:latest }
}

export def 'main digitiser_aggregator' [] {
    switch_dir { buildah bud -f Containerfile --build-arg component=digitiser-aggregator -t supermusr-digitiser-aggregator:latest }
}

export def 'main nexus_writer' [] {
    switch_dir { buildah bud -f Containerfile --build-arg component=nexus-writer -t supermusr-nexus-writer:latest }
}

export def main [] {
    switch_dir {
        buildah bud -f Containerfile --build-arg component=trace-to-events -t supermusr-trace-to-events:latest
        buildah bud -f Containerfile --build-arg component=digitiser-aggregator -t supermusr-digitiser-aggregator:latest
        buildah bud -f Containerfile --build-arg component=nexus-writer -t supermusr-nexus-writer:latest
        buildah bud -f Containerfile --build-arg component=simulator -t supermusr-simulator:latest
    }
}