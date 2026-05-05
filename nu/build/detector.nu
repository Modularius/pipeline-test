const int_interval_type = "record<min: int, max: int, dflt: int>"
const float_interval_type = "record<min: float, max: float, dflt: float>"

def get_bool [ name: string ] : record  -> bool {
    if ($in | get $name) {
        [$name]
    } else {
        []
    }
}

def build_from_intervals_inner [] : any -> any {
    mut value = $in
    let descr = ($value | describe -d)
    if $descr.detailed_type == $int_interval_type {
        $value = random int $value.min..$value.max
    } else if $descr.detailed_type == $float_interval_type {
        $value = random float $value.min..$value.max
    } else if $descr.type == "record" {
        $value = $value | select_from_intervals
    } else if $descr.type == "list" {
        $value = $value | each {|val| $val | build_record_from_random_intervals}
    }
    $value
}

export def build_record_from_random_intervals [] : record -> record {
    mut detector = $in
    for field in ($detector | columns) {
        let value = $detector | get $field
        let new_value = $value | build_from_intervals_inner
        $detector = $detector | update $field $new_value
    }
    $detector
}

def get_pair [ name: string ] : record  -> list<string> {
    [("--" ++ $name), ($in | get $name | into string) ]
}

def get_vector [ name: string ] : record  -> list<string> {
    [("--" ++ $name)=($in | get $name | str join "," )]
}

def build_fixed_threshold [ src: record ] : nothing  -> list<string> {
    ($src | get "type")
    | append ($src | get_pair threshold)
    | append ($src | get_pair duration)
    | append ($src | get_pair cool-off)
}

def build_differential_threshold [ src: record ] : nothing  -> list<string> {
    ($src | get "type")
    | append ($src | get_pair begin-threshold)
    | append ($src | get_pair end-threshold)
    | append ($src | get_pair begin-duration)
    | append ($src | get_pair end-duration)
    | append ($src | get_pair cool-off)
    | append ($src | get_pair peak-height-mode)
    | append ($src | get_pair peak-height-basis)
}

def build_smoothing [ src: record ] : nothing  -> list<string> {
    ($src | get "type")
    | append ($src | get_pair noise-centile)
    | append ($src | get_pair kernel-sigma)
    | append ($src | get_pair nsig-noise)
    | append ($src | get_pair min-size)
}

def build_multiscaling [ src: record ] : nothing  -> list<string> {
    ($src | get "type")
    | append ($src | get_vector downsampling-smoothing)
    | append ($src | get_vector smoothing-support)
    | append ($src | get_pair fft-padding)
    | append ($src | get_pair fft-truncation)
    | append ($src | get_pair number-of-layers)
    | append ($src | get_bool denoise)
    | append ($src | get_vector denoise-thresholds)
    | append ($src | get_bool enhance)
    | append ($src | get_vector enhance-thresholds)
    | append ($src | get_vector enhance-factors)
    | append ($src | get_bool multiply)
    | append ($src | get_vector multiply-factors)
    | append (($src | get "underlying") | build_detector)
}

export def build_detector [] : record -> list<string> {
    let detector = $in
    match ($detector | get "type") {
        "fixed-threshold-discriminator" => (build_fixed_threshold $detector),
        "differential-threshold-discriminator" => (build_differential_threshold $detector),
        "smoothing-detector" =>  (build_smoothing $detector),
        "multiscaling" => (build_multiscaling $detector),
    }
}