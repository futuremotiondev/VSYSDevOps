function Convert-JsonKeysToCommaSeparatedString {
    param (
        [Parameter(Mandatory = $true)]
        [string]$JsonString
    )

    $jsonObject = $JsonString | ConvertFrom-Json -AsHashTable
    $modifiedKeys = @()

    foreach ($key in $jsonObject.Keys) {
        # Remove leading and trailing spaces and symbols, but keep alphanumeric and Unicode code-point characters
        $trimmedKey = $key.Trim()
        $newKey = $trimmedKey -replace '[^\p{L}\p{Nd}\u00C0-\u017F]', ''

        # Decode Unicode code points in the key
        $newKey = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($newKey))

        # Skip if newKey is empty, just a comma, or if it does not contain any alphanumeric/Unicode code-point character
        if (-not $newKey -or $newKey -match '^,+$' -or -not ($newKey -match '\w' -or $newKey -match '\\u')) {
            continue
        }

        # Add the modified key to the list
        $modifiedKeys += $newKey
    }

    # Output as a comma-separated string without quotes
    return $modifiedKeys -join ","
}