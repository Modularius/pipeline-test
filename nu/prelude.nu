export def print_heading [colour?: string] : string -> nothing {
    let colour = $colour | default "red"
    $"(ansi $colour)(ansi bo)($in)(ansi reset)" | print
}