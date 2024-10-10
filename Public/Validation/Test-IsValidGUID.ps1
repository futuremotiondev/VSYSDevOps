function Test-IsValidGuid {
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ObjectGuid
    )

    [regex]$guidRegex = '(?im)^[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$'
    return $ObjectGuid -match $guidRegex
}
