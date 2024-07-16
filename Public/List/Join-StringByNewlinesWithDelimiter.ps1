function Join-StringByNewlinesWithDelimiter {
    [OutputType([string])]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string] $InputString,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $Delimiter
    )

    process {
        $lines = $InputString -split "`r`n"
        if ($lines.Count -eq 1) { $lines = $multiLineString -split "`n" }
        $outputStr = ($lines | ForEach-Object { $_.Trim() } | Where-Object {
            $_ -ne ''
        }) -join "$Delimiter"
        $outputStr
    }
}