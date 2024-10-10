using namespace System.Text.RegularExpressions
function ConvertTo-RegSZUnescaped {
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]] $String
    )
    process {
        $String = $String.Trim()
        $val = $String -replace '"$', ''
        $val = $val -replace '^"', ''
        $val = $val -replace [regex]::Escape('\"'), '"'
        $val = $val -replace [regex]::Escape('\\'), '\'
        $val
    }
}