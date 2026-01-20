export def "print heading" [text:string] {
    $"(ansi red)(ansi bo)($text)(ansi reset)" | print
}