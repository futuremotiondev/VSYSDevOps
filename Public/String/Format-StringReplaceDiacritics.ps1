function Format-StringReplaceDiacritics {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('s')]
        [String[]] $String
    )

    process {
        $String | ForEach-Object {
            $NewString = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($_))
            $NewString = $NewString -replace '\?', ''
            $NewString = $NewString -replace '\s{2,}', ' '
            $NewString
        }
    }
}
