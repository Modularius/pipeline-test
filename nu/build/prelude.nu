export const HEADING_COLOUR = "red"
export const SUBHEADING_COLOUR = "yellow"
export const SUBSUBHEADING_COLOUR = "green"
export const SUBSUBSUBHEADING_COLOUR = "blue"

export def print_title [] : string -> nothing {
    let strlen = $in | str length
    $"(ansi bo)($in
        | ansi gradient --fgstart "0xFFCBaa" --fgend "0x56D095"
    )(ansi reset)" | print
}

export def print_heading [colour: string] : string -> nothing {
    let strlen = $in | str length
    let width = match $colour {
        "red" => 2
        "yellow" => 4
        "green" => 6
        "blue" => 8
    }
    $"(ansi $colour)(ansi bo)($in
        | fill --width ($strlen + $width) --alignment "r"
    )(ansi reset)" | print
}

export def print_gradient_heading [colour: string, colour2: string] : string -> nothing {
        $"(ansi bo)($in | ansi gradient --fgstart $colour --fgend $colour2)(ansi reset)" | print
}