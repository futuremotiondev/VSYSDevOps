Function Test-DirectoryIsEmpty {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0)]
        [string] $Directory
    )

    if (-not(Test-Path -Path $Directory -PathType Container)) {
        Write-Warning "The directory '$Directory' does not exist."
        return $false
    }

    $Items = Get-ChildItem -Path $Directory -Force -Recurse
    if ($Items.Count -eq 0) {
        return $true
    }
    else {
        return $false
    }
}