let settings: record = open "settings.json"

const kakfa_path = "podman"
const kakfa_args = ["exec", "redpanda", "rpk", "topic"]

export def 'main' [] {
    ^$kakfa_path ...$kakfa_args ls
}

export def 'main create' [...topics: string] {
    let topics = if ($topics | is-empty) { $settings.broker.topics | values } else { $topics }
    ^$kakfa_path ...$kakfa_args create ...$topics
}

export def 'main destroy' [...topics: string] {
    let topics = if ($topics | is-empty) { $settings.broker.topics | values } else { $topics }
    ^$kakfa_path ...$kakfa_args delete ...$topics
}

export def 'main recreate' [...topics: string] {
    let topics = if ($topics | is-empty) { $settings.broker.topics | values } else { $topics }
    ^$kakfa_path ...$kakfa_args delete ...$topics
    ^$kakfa_path ...$kakfa_args create ...$topics
}