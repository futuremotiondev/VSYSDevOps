function Test-PathContainsWildcards {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [string[]] $Path
    )
    process {
        $wildcards = '*?[]'
        ($Path.IndexOfAny($wildcards.ToCharArray()) -ge 0) ? $true : $false
    }
}
