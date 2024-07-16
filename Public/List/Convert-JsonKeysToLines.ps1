function Convert-JsonKeysToLines {
    param (
        [Parameter(Mandatory = $true)]
        [string]$JsonString,
        [Parameter(Mandatory = $false)]
        [switch]$IncludeLineNumbers
    )

    $jsonObject = $JsonString | ConvertFrom-Json -AsHashTable
    $modifiedKeys = @()

    # First pass to filter and decode keys to determine total line number
    foreach ($key in $jsonObject.Keys) {
        $trimmedKey = $key.Trim()
        $newKey = $trimmedKey -replace '[^\p{L}\p{Nd}\u00C0-\u017F]', ''
        $newKey = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($newKey))

        if (-not $newKey -or $newKey -match '^,+$' -or -not ($newKey -match '\w' -or $newKey -match '\\u')) {
            continue
        }

        $modifiedKeys += $newKey
    }

    $totalLines = $modifiedKeys.Count
    $lineNumberLength = $totalLines.ToString().Length
    $lineNumber = 1
    $outputLines = @()

    foreach ($key in $modifiedKeys) {
        if ($IncludeLineNumbers) {
            # Format line number with leading zeros
            $formattedLineNumber = $lineNumber.ToString().PadLeft($lineNumberLength, '0')
            $outputLines += "$($formattedLineNumber): $key"
        } else {
            $outputLines += $key
        }

        $lineNumber++
    }

    # Output each modified key on a new line
    return $outputLines -join "`n"
}
