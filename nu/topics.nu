let settings: record = open "settings.json"

const kakfa_path = "rpk"
const kakfa_args = ["topic"]

export def 'main' [] {
    ^$kakfa_path ...$kakfa_args ls
}

export def 'main create' [topics?: list<string>] {
    let topics = $topics | default $settings.broker.topics
    ^$kakfa_path ...$kakfa_args create ...($topics | values)
}

export def 'main destroy' [topics?: list<string>] {
    let topics = $topics | default $settings.broker.topics
    ^$kakfa_path ...$kakfa_args delete ...($topics | values)
}

export def 'main recreate' [topics?: list<string>] {
    let topics = $topics | default $settings.broker.topics
    ^$kakfa_path ...$kakfa_args delete ...($topics | values)
    ^$kakfa_path ...$kakfa_args create ...($topics | values)
}