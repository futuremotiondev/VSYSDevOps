Function Remove-ANSICodesFromString {
    Param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$String
    )

    # Regular expression pattern to match ANSI escape sequences
    $AnsiPattern = "`e\[\d+(;\d+)*m"

    # Replace the ANSI escape sequences with an empty string
    $CleanString = $String -replace $AnsiPattern, ''

    Return $CleanString
}